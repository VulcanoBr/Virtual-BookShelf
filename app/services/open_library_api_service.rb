class OpenLibraryApiService
  include HTTParty
  base_uri 'https://openlibrary.org'

  def initialize
    # Open Library não necessita de API key
  end

  def search(query, options = {})
    options = default_options.merge(options)
    # Transformar o query de Google Books para formato Open Library
    search_term = format_query(query)

    response = self.class.get('/search.json', query: {
      q: search_term,
      limit: options[:per_page],
      offset: (options[:page] - 1) * options[:per_page],
      fields: 'key,title,author_name,publisher,publish_date,isbn,cover_i,edition_count,edition_key,subject,language'
    })

    if response.success?
      parse_response(response)
    else
      { error: "API Error: #{response.code} #{response.message}" }
    end
  end

  def find_by_isbn(isbn)
    response = self.class.get("/isbn/#{isbn}.json")
    if response.success?
      parse_book_by_isbn(response)
    else
      nil
    end
  end

  def find_by_id(id)
    # Open Library usa um formato diferente de ID, geralmente começa com /works/
    # Se o ID não estiver no formato esperado, tentamos ajustá-lo
    id = "/works/#{id}" unless id.start_with?('/works/')

    response = self.class.get("#{id}.json")
    if response.success?
      parse_book_by_id(response, id)
    else
      nil
    end
  end

  private

  def default_options
    {
      page: 1,
      per_page: 10
    }
  end

  def format_query(query)
    # Converter formato do Google Books para Open Library
    if query.include?('intitle:')
      query.gsub('intitle:', 'title:')
    elsif query.include?('inauthor:')
      query.gsub('inauthor:', 'author:')
    elsif query.include?('isbn:')
      query.gsub('isbn:', 'isbn:')
    else
      query
    end
  end

  def parse_response(response)
    results = response['docs'] || []

    {
      total_items: response['numFound'] || 0,
      items: results.map { |item| parse_search_result(item) }
    }
  end

  def parse_search_result(item)
    # ID em Open Library geralmente é o key (exemplo: /works/OL123W)
    work_key = item['key']
    id = work_key&.gsub('/works/', '')

    # Buscar detalhes adicionais do livro (descrição, número de páginas, etc.)
    book_details = get_work_details(work_key) if work_key

    # Buscar informações de edição para obter número de páginas e idioma
    edition_info = get_edition_info(item['edition_key']&.first) if item['edition_key']&.any?

    {
      id: id,
      title: item['title'],
      subtitle: nil, # Open Library não fornece subtítulo separadamente
      authors: item['author_name'],
      publisher: item['publisher']&.first,
      published_date: item['publish_date']&.first,
      description: book_details&.dig('description')&.is_a?(Hash) ? book_details['description']['value'] : book_details&.dig('description'),
      page_count: edition_info&.dig('number_of_pages'),
      categories: item['subject'] || book_details&.dig('subjects'),
      # A cover_i é o ID da capa, precisa ser convertida em URL
      thumbnail: item['cover_i'] ? "https://covers.openlibrary.org/b/id/#{item['cover_i']}-M.jpg" : nil,
      preview_link: "https://openlibrary.org#{work_key}",
      info_link: "https://openlibrary.org#{work_key}",
      buy_link: nil, # Open Library não fornece links de compra
      isbn: item['isbn']&.first,
      language: edition_info&.dig('languages')&.map { |l| get_language_name(l['key']) },
      retail_price: nil, # Open Library não fornece informações de preço
      currency: nil,
      availability: nil
    }
  end

  def parse_book_by_isbn(data)
    # Este método lida com os detalhes de um livro específico por ISBN
    work_key = data['works']&.first&.dig('key')
    work_details = get_work_details(work_key) if work_key

    {
      id: work_key&.gsub('/works/', ''),
      title: data['title'],
      subtitle: nil,
      authors: data['authors']&.map { |a| a['name'] },
      publisher: data['publishers']&.first,
      published_date: data['publish_date'],
      description: data['description']&.is_a?(Hash) ? data['description']['value'] : data['description'] || work_details&.dig('description')&.is_a?(Hash) ? work_details['description']['value'] : work_details&.dig('description'),
      page_count: data['number_of_pages'],
      categories: data['subjects'] || work_details&.dig('subjects'),
      thumbnail: data['covers']&.first ? "https://covers.openlibrary.org/b/id/#{data['covers'].first}-M.jpg" : nil,
      preview_link: "https://openlibrary.org#{work_key}",
      info_link: "https://openlibrary.org#{work_key}",
      buy_link: nil,
      isbn: data['isbn_13']&.first || data['isbn_10']&.first,
      language: data['languages']&.map { |l| get_language_name(l['key']) },
      retail_price: nil,
      currency: nil,
      availability: nil
    }
  end

  def parse_book_by_id(data, id)
    # Este método lida com os detalhes de um livro específico por ID de trabalho
    # Buscar a primeira edição para obter mais detalhes
    edition_key = data['first_publish_edition']
    edition_info = get_edition_info("OL#{edition_key}M") if edition_key

    {
      id: id.gsub('/works/', ''),
      title: data['title'],
      subtitle: nil,
      authors: data['authors']&.map { |a| get_author_name(a['author']['key']) },
      publisher: edition_info&.dig('publishers')&.first,
      published_date: edition_info&.dig('publish_date') || data['first_publish_date'],
      description: data['description']&.is_a?(Hash) ? data['description']['value'] : data['description'],
      page_count: edition_info&.dig('number_of_pages'),
      categories: data['subjects'],
      thumbnail: data['covers']&.first ? "https://covers.openlibrary.org/b/id/#{data['covers'].first}-M.jpg" : nil,
      preview_link: "https://openlibrary.org#{id}",
      info_link: "https://openlibrary.org#{id}",
      buy_link: nil,
      isbn: edition_info&.dig('isbn_13')&.first || edition_info&.dig('isbn_10')&.first,
      language: edition_info&.dig('languages')&.map { |l| get_language_name(l['key']) },
      retail_price: nil,
      currency: nil,
      availability: nil
    }
  end

  def get_author_name(author_key)
    # Método auxiliar para buscar nome do autor quando só temos a chave
    response = self.class.get("#{author_key}.json")
    response.success? ? response['name'] : 'Unknown Author'
  end

  # Métodos auxiliares para obter dados adicionais

  def get_work_details(work_key)
    # Busca os detalhes completos de um trabalho/livro pelo seu key
    # Exemplo de work_key: "/works/OL1234W"
    response = self.class.get("#{work_key}.json")
    response.success? ? response : nil
  end

  def get_edition_info(edition_key)
    # Busca informações de uma edição específica
    # As edições contêm detalhes como número de páginas e idioma
    response = self.class.get("/books/#{edition_key}.json")
    response.success? ? response : nil
  end

  def get_language_name(language_key)
    # Converte o código de idioma em nome legível
    # Exemplo: /languages/eng -> English
    response = self.class.get("#{language_key}.json")
    response.success? ? response['name'] : 'Unknown Language'
  end
end
