Rails.application.routes.draw do

  root "home#index"

  # Rotas para autenticação
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  # Rotas para cadastro de usuários
  get '/signup', to: 'users#new'
  resources :users, only: [:create, :show, :edit, :update]

  # Rotas para livros
  resources :books, only: [:index, :show, :new, :create] do
    collection do
      get 'search'
    end
    member do
      get 'import'
      post 'add_to_bookshelf'
    end

    resources :bookshelf_items, only: [:create, :destroy] # Você pode adicionar :destroy depois
  end

  get 'books/preview/:id', to: 'books#preview', as: 'preview_book'

  # Rotas para estantes
  resources :bookshelves do
    member do
      post 'add_book'
      delete 'remove_book'
      post 'update_book_status'
    end
  end

end
