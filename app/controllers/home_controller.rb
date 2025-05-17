
class HomeController < ApplicationController

  def index
    @recent_books = Book.order(created_at: :desc).limit(6)

    if current_user
      @user_bookshelves = current_user.bookshelves.includes(:books).limit(2)
    end
  end
end
