class User < ApplicationRecord

  has_secure_password
  has_many :bookshelves, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 6 }, if: :password_digest_changed?
  validates :first_name, presence: true

  after_create :create_default_bookshelves

  def full_name
    "#{first_name} #{last_name}".strip
  end

  private

  def create_default_bookshelves
    # Criar estantes padrão para novos usuários
    Bookshelf.create(name: "Lidos", user: self)
    Bookshelf.create(name: "Lista de Desejos", user: self)
  end

end
