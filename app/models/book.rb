class Book < ApplicationRecord

  has_many :bookshelf_items, dependent: :destroy
  has_many :bookshelves, through: :bookshelf_items

  validates :title, presence: true
  validates :isbn, uniqueness: true, allow_blank: true

  def self.OLD_find_or_create_from_api_data(book_data)
    isbn = book_data.dig('volumeInfo', 'industryIdentifiers')&.find { |id| id['type'] == 'ISBN_13' }&.dig('identifier')

    # Procurar pelo ISBN se disponível, senão pelo ID do Google Books
    existing_book = isbn.present? ? find_by(isbn: isbn) : find_by(google_books_id: book_data['id'])

    return existing_book if existing_book

    # Se não existir, criar um novo livro com os dados da API
    volume_info = book_data['volumeInfo']

    create(
      title: volume_info['title'],
      subtitle: volume_info['subtitle'],
      authors: volume_info['authors']&.join(', '),
      publisher: volume_info['publisher'],
      published_date: volume_info['publishedDate'],
      language: volume_info['language'],
      description: volume_info['description'],
      page_count: volume_info['pageCount'],
      categories: volume_info['categories']&.join(', '),
      thumbnail_url: volume_info.dig('imageLinks', 'thumbnail'),
      preview_link: volume_info['previewLink'],
      info_link: volume_info['infoLink'],
      isbn: isbn,
      google_books_id: book_data['id']
    )
  end

  def self.find_or_create_from_api_data(book_data_for_import)
    google_id = book_data_for_import[:id]
    api_book_data = book_data_for_import  # api_data_wrapper['volumeInfo'] # Renomeado para clareza
    book = find_by(google_books_id: google_id) # Assumindo que você armazena o ID do Google Books
    return book if book

    # Mapeie os dados da API para os atributos do seu modelo
    # Exemplo simplificado:
    new_book = new(
      google_books_id: google_id,
      title: api_book_data[:title],
      subtitle: api_book_data[:subtitle],
      authors: api_book_data[:authors]&.join(', '),
      publisher: api_book_data[:publisher],
      published_date: api_book_data[:published_date],
      language: api_book_data[:language],
      description: api_book_data[:description],
      page_count: api_book_data[:page_count],
      thumbnail_url: api_book_data.dig(:thumbnail),
      categories: api_book_data[:categories]&.join(', '),
      preview_link: api_book_data[:preview_link],
      info_link: api_book_data[:info_link],

      isbn: api_book_data[:isbn]

    )

    if new_book.save
      new_book
    else
      Rails.logger.error "Falha ao salvar livro da API: #{google_id}. Erros: #{new_book.errors.full_messages.join(', ')}"
      nil # Retorna nil se a gravação falhar
    end
  end

end
