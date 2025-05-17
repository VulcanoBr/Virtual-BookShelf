
  class BookshelfItemsController < ApplicationController

    before_action :authenticate_user!
    before_action :set_book

    # POST /books/:book_id/bookshelf_items
    def create
      # O bookshelf_id virá dos parâmetros do formulário, de bookshelf_item[bookshelf_id]
      selected_bookshelf = current_user.bookshelves.find_by(id: bookshelf_item_params[:bookshelf_id])

      if selected_bookshelf.nil?
        redirect_to @book, alert: "Estante selecionada inválida ou não encontrada."
        return
      end

      # Verifica se o item já existe para evitar duplicatas
      @bookshelf_item = selected_bookshelf.bookshelf_items.find_by(book_id: @book.id)

      if @bookshelf_item
        # Se já existe, atualizar o status? Ou apenas informar.
        if @bookshelf_item.update(status: bookshelf_item_params[:status])
          redirect_to @book, notice: "Status do livro na estante '#{selected_bookshelf.name}' atualizado."
        else
          redirect_to @book, alert: "Não foi possível atualizar o status do livro: #{@bookshelf_item.errors.full_messages.join(', ')}"
        end
        redirect_to @book, notice: "Este livro já está na estante '#{selected_bookshelf.name}'."
      else
        # Cria um novo BookshelfItem
        @bookshelf_item = selected_bookshelf.bookshelf_items.new(book: @book, status: bookshelf_item_params[:status])

        if @bookshelf_item.save
          redirect_to @book, notice: "Livro Item adicionado à estante '#{selected_bookshelf.name}'."
        else
          # É melhor re-renderizar a view 'books/show' com os erros, mas isso é mais complexo.
          # Por enquanto, um redirect com alerta é mais simples.
          flash[:alert] = "Não foi possível adicionar o livro à estante: #{@bookshelf_item.errors.full_messages.join(', ')}"
          redirect_to @book # Ou render 'books/show', status: :unprocessable_entity (mas precisaria @book e outras vars de show)
        end
      end
    end

    # DELETE /books/:book_id/bookshelf_items/:id
    def destroy
      # :id aqui é o bookshelf_item_id
      @bookshelf_item = @book.bookshelf_items.find_by(id: params[:id]) # Encontra o item associado ao @book
      # Verifique se o item pertence a uma estante do current_user
      if @bookshelf_item && @bookshelf_item.bookshelf.user == current_user
        bookshelf_name = @bookshelf_item.bookshelf.name
        @bookshelf_item.destroy
        redirect_to @book, notice: "Livro Item removido da estante '#{bookshelf_name}'."
      else
        redirect_to @book, alert: "Item não encontrado ou você não tem permissão para removê-lo."
      end
    end

    private

    def set_book
      @book = Book.find(params[:book_id])
    end

    def bookshelf_item_params
      # bookshelf_id e status virão do formulário
      params.require(:bookshelf_item).permit(:bookshelf_id, :status)
    end
  end
