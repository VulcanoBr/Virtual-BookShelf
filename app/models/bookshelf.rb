class Bookshelf < ApplicationRecord

  belongs_to :user
  has_many :bookshelf_items, dependent: :destroy
  has_many :books, through: :bookshelf_items

  validates :name, presence: true

  def add_book(book, status = nil)
    return if books.include?(book)

    bookshelf_items.create(book: book, status: status)
  end

  def remove_book(book)
    bookshelf_items.find_by(book: book)&.destroy
  end

end
