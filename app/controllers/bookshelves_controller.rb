class BookshelvesController < ApplicationController

  before_action :authenticate_user!

  before_action :set_bookshelf, only: [:show, :edit, :update, :destroy]

  # GET /bookshelves
  def index
    @bookshelves = current_user.bookshelves
  end

  def show
    # Aplicar filtros de pesquisa, status e ordenação
    query = @bookshelf.bookshelf_items.includes(:book)

    # Filtro por título ou autor
    if params[:search].present?
      query = query.joins(:book).where("books.title ILIKE ? OR books.authors ILIKE ?",
                                      "%#{params[:search]}%", "%#{params[:search]}%")
    end

    # Filtro por status
    if params[:status].present?
      query = query.where(status: params[:status])
    end

    # Ordenação
    case params[:sort]
    when 'title_asc'
      query = query.joins(:book).order('books.title ASC')
    when 'title_desc'
      query = query.joins(:book).order('books.title DESC')
    when 'added_asc'
      query = query.order(created_at: :asc)
    else # 'added_desc' ou padrão
      query = query.order(created_at: :desc)
    end

    @bookshelf_items = query.page(params[:page] || 1).per(6)
  end

  # GET /bookshelves/new
  def new
    @bookshelf = current_user.bookshelves.new
  end

  # GET /bookshelves/1/edit
  def edit
  end

  # POST /bookshelves
  def create
    @bookshelf = current_user.bookshelves.new(bookshelf_params)

    if @bookshelf.save
      redirect_to @bookshelf, notice: 'Estante criada com sucesso.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /bookshelves/1
  def update
    if @bookshelf.update(bookshelf_params)
      redirect_to @bookshelf, notice: 'Estante atualizada com sucesso.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /bookshelves/1
  def destroy
    @bookshelf.destroy
    redirect_to bookshelves_url, notice: 'Estante removida com sucesso.'
  end

  def update_book_status
    @bookshelf = current_user.bookshelves.find(params[:id])
    @book = Book.find(params[:book_id])
    @bookshelf_item = @bookshelf.bookshelf_items.find_by(book_id: params[:book_id])

    if @bookshelf_item&.update(status: params[:status])
      redirect_to @bookshelf, notice: 'Status do livro atualizado com sucesso.'
    else
      redirect_to @bookshelf, alert: 'Não foi possível atualizar o status do livro.'
    end
  end

  # POST /bookshelves/1/add_book
  def add_book
    @bookshelf = current_user.bookshelves.find(params[:id])
    @book = Book.find(params[:book_id])

    if @bookshelf.add_book(@book, params[:status])
      redirect_to @book, notice: "Livro adicionado à estante #{@bookshelf.name}."
    else
      redirect_to @book, alert: 'Não foi possível adicionar o livro à estante.'
    end
  end

  # DELETE /bookshelves/1/remove_book
  def remove_book
    @bookshelf = current_user.bookshelves.find(params[:id])
    @book = Book.find(params[:book_id])

    if @bookshelf.remove_book(@book)
      redirect_to @bookshelf, notice: 'Livro removido da estante.'
    else
      redirect_to @bookshelf, alert: 'Não foi possível remover o livro da estante.'
    end
  end

  private

  def set_bookshelf
    @bookshelf = current_user.bookshelves.find(params[:id])
  end

  def bookshelf_params
    params.require(:bookshelf).permit(:name)
  end
end
