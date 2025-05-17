class CreateBookshelves < ActiveRecord::Migration[7.2]
  def change
    create_table :bookshelves do |t|
      t.string :name, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :bookshelves, [:user_id, :name], unique: true
  end
end
