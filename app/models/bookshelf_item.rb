class BookshelfItem < ApplicationRecord

  belongs_to :bookshelf
  belongs_to :book

  # Status pode ser usado para indicar "lendo", "finalizado", etc.
  validates :status, inclusion: { in: %w[want_to_read reading read], allow_nil: true }

end
