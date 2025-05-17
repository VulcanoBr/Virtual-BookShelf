class BooksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_book, only: [:show]

  # GET /books
  def index
    @books = Book.page(params[:page] || 1).per(8)
  end

  # GET /books/1
  def show
    @bookshelf_item = current_user&.bookshelves&.map do |bookshelf|
      bookshelf_item = bookshelf.bookshelf_items.find_by(book: @book)
      { bookshelf: bookshelf, item: bookshelf_item } if bookshelf_item
    end&.compact&.first
  end

  def search
    @query = params[:q]
    @type = params[:type] || 'title'

    if @query.present?
      api_service = GoogleBooksApiService.new
      @page = (params[:page] || 1).to_i

      query_params = case @type
                     when 'title'
                       "intitle:#{@query}"
                     when 'author'
                       "inauthor:#{@query}"
                     when 'isbn'
                       "isbn:#{@query}"
                     else
                       @query
                     end

      @search_results = api_service.search(query_params, page: @page, per_page: 10)

      if @search_results[:items].present?
        @search_results[:items].each do |book_data|
          Rails.cache.write(cache_key_for_book(book_data[:id]), book_data, expires_in: 15.minutes)
        end
      end
    else
      @search_results = { total_items: 0, items: [] }
    end
  end

  def preview
    book_id = params[:id]
    @book_data = Rails.cache.read(cache_key_for_book(book_id))

    unless @book_data
      api_service = GoogleBooksApiService.new
      @book_data = api_service.find_by_id(book_id)

      if @book_data
        Rails.cache.write(cache_key_for_book(book_id), @book_data, expires_in: 15.minutes)
      end
    end

    if @book_data
      @existing_book = Book.find_by(google_books_id: book_id)
      render :preview
    else
      redirect_to search_books_path, alert: 'Não foi possível encontrar o livro (nem no cache, nem na API externa).'
    end
  end

  def create
    @book = Book.new(book_params)

    if @book.save
      redirect_to @book, notice: 'Livro criado com sucesso.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def import
    book_id = params[:id]
    @book = import_book_from_google(book_id)

    if @book&.persisted?
      redirect_to @book, notice: 'Livro importado com sucesso.'
    else
      error_message = if @book&.errors&.any?
                        "Erro ao processar dados do livro: #{@book.errors.full_messages.join(', ')}"
                      else
                        "Não foi possível processar os dados do livro (do cache/API)."
                      end
      redirect_to search_books_path, alert: error_message
    end
  end

  def add_to_bookshelf
    book_id = params[:id]
    bookshelf_id = params[:bookshelf_id]
    status = params[:status].presence

    @book = import_book_from_google(book_id)

    if @book&.persisted?
      bookshelf = current_user.bookshelves.find_by(id: bookshelf_id)

      if bookshelf
        existing_item = bookshelf.bookshelf_items.find_by(book: @book)

        if existing_item
          redirect_to @book, alert: 'Este livro já está nesta estante.'
        else
          bookshelf_item = bookshelf.bookshelf_items.new(book: @book, status: status)

          if bookshelf_item.save
            redirect_to @book, notice: "Livro adicionado à estante '#{bookshelf.name}' com sucesso."
          else
            redirect_to preview_book_path(book_id), alert: "Erro ao adicionar à estante: #{bookshelf_item.errors.full_messages.join(', ')}"
          end
        end
      else
        redirect_to preview_book_path(book_id), alert: 'Estante não encontrada.'
      end
    else
      error_message = if @book&.errors&.any?
                        "Erro ao processar dados do livro: #{@book.errors.full_messages.join(', ')}"
                      else
                        "Não foi possível processar os dados do livro."
                      end
      redirect_to preview_book_path(book_id), alert: error_message
    end
  end

  private

  def set_book
    @book = Book.find(params[:id])
  end

  def book_params
    params.require(:book).permit(:title, :subtitle, :authors, :publisher, :published_date,
                    :language, :description, :page_count, :categories, :thumbnail_url,
                    :preview_link, :info_link, :isbn, :google_books_id)
  end

  def cache_key_for_book(book_id)
    "book_data:#{book_id}"
  end

  def import_book_from_google(book_id)
    book_data_for_import = Rails.cache.read(cache_key_for_book(book_id))

    unless book_data_for_import
      api_service = GoogleBooksApiService.new
      book_data_for_import = api_service.find_by_id(book_id)

      if book_data_for_import
        Rails.cache.write(cache_key_for_book(book_id), book_data_for_import, expires_in: 15.minutes)
      end
    end

    if book_data_for_import
      Book.find_or_create_from_api_data(book_data_for_import)
    else
      nil
    end
  end
end
