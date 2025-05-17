class CreateBooks < ActiveRecord::Migration[7.2]
  def change
    create_table :books do |t|
      t.string :external_id
      t.string :title, null: false
      t.string :subtitle
      t.string :isbn
      t.string :authors
      t.string :publisher
      t.string :published_date
      t.string :language
      t.text :description
      t.integer :page_count
      t.string :categories
      t.string :thumbnail_url
      t.string :preview_link
      t.string :info_link
      t.string :google_books_id

      t.timestamps
    end
    add_index :books, :isbn, unique: true
    add_index :books, :google_books_id, unique: true
  end
end
