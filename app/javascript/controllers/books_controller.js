import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="books"
export default class extends Controller {
  connect() {
    this.element.textContext = 'Api Books'
  }
  storeBook(event) {
    // Obter os dados do livro do atributo data-book-data
    const bookData = JSON.parse(event.currentTarget.dataset.bookData)

    // Armazenar no sessionStorage para acesso na próxima página
    sessionStorage.setItem('selectedBook', JSON.stringify(bookData))
  }
}
