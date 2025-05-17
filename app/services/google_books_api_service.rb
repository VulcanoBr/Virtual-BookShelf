class GoogleBooksApiService
  include HTTParty
  base_uri 'https://www.googleapis.com/books/v1'

  def initialize
    @api_key = ENV['GOOGLE_BOOKS_API_KEY']
  end

  def search(query, options = {})
    options = default_options.merge(options)

    response = self.class.get('/volumes', query: {
      q: build_query(query),
      maxResults: options[:per_page],
      startIndex: (options[:page] - 1) * options[:per_page],
      key: @api_key
    })

    if response.success?
      parse_response(response)
    else
      { error: "API Error: #{response.code} #{response.message}" }
    end
  end

  def find_by_isbn(isbn)
    response = self.class.get('/volumes', query: {
      q: "isbn:#{isbn}",
      key: @api_key
    })

    if response.success? && response['totalItems'] > 0
      parse_book(response['items'].first)
    else
      nil
    end
  end

  def find_by_id(id)
    response = self.class.get("/volumes/#{id}", query: { key: @api_key })

    if response.success?
      parse_book(response)
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

  def build_query(query)
    return query unless query.is_a?(Hash)

    query.map do |field, value|
      "#{field}:#{value}"
    end.join('+')
  end

  def parse_response(response)
    {
      total_items: response['totalItems'] || 0,
      items: response['items']&.map { |item| parse_book(item) } || []
    }
  end

  def parse_book(item)
    volume_info = item['volumeInfo'] || {}
    sale_info = item['saleInfo'] || {}

    {
      id: item['id'],
      title: volume_info['title'],
      subtitle: volume_info['subtitle'],
      authors: volume_info['authors'],
      publisher: volume_info['publisher'],
      published_date: volume_info['publishedDate'],
      language: volume_info['language'],
      description: volume_info['description'],
      page_count: volume_info['pageCount'],
      categories: volume_info['categories'],
      thumbnail: volume_info.dig('imageLinks', 'thumbnail'),
      preview_link: volume_info['previewLink'],
      info_link: volume_info['infoLink'],
      buy_link: sale_info['buyLink'],
      isbn: extract_isbn(volume_info['industryIdentifiers']),
      retail_price: sale_info.dig('retailPrice', 'amount'),
      currency: sale_info.dig('retailPrice', 'currencyCode'),
      availability: sale_info['availability']
    }

  end

  def extract_isbn(identifiers)
    return nil unless identifiers&.any?

    isbn13 = identifiers.find { |id| id['type'] == 'ISBN_13' }
    isbn10 = identifiers.find { |id| id['type'] == 'ISBN_10' }

    (isbn13 || isbn10)&.dig('identifier')
  end
end
