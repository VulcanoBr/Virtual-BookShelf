# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_05_07_191328) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "books", force: :cascade do |t|
    t.string "external_id"
    t.string "title", null: false
    t.string "subtitle"
    t.string "isbn"
    t.string "authors"
    t.string "publisher"
    t.string "published_date"
    t.string "language"
    t.text "description"
    t.integer "page_count"
    t.string "categories"
    t.string "thumbnail_url"
    t.string "preview_link"
    t.string "info_link"
    t.string "google_books_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["google_books_id"], name: "index_books_on_google_books_id", unique: true
    t.index ["isbn"], name: "index_books_on_isbn", unique: true
  end

  create_table "bookshelf_items", force: :cascade do |t|
    t.bigint "bookshelf_id", null: false
    t.bigint "book_id", null: false
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_bookshelf_items_on_book_id"
    t.index ["bookshelf_id", "book_id"], name: "index_bookshelf_items_on_bookshelf_id_and_book_id", unique: true
    t.index ["bookshelf_id"], name: "index_bookshelf_items_on_bookshelf_id"
  end

  create_table "bookshelves", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "name"], name: "index_bookshelves_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_bookshelves_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "bookshelf_items", "books"
  add_foreign_key "bookshelf_items", "bookshelves"
  add_foreign_key "bookshelves", "users"
end
