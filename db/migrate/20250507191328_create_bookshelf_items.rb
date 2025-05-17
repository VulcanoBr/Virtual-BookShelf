class CreateBookshelfItems < ActiveRecord::Migration[7.2]
  def change
    create_table :bookshelf_items do |t|
      t.references :bookshelf, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.string :status

      t.timestamps
    end
    add_index :bookshelf_items, [:bookshelf_id, :book_id], unique: true
  end
end
