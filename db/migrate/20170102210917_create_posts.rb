class CreatePosts < ActiveRecord::Migration[5.0]
  def change
    create_table :posts do |t|
      t.string :title, null: false
      t.text :body, null: false
      t.string :permalink, null: false
      t.string :image_url
      t.boolean :published, null: false, default: false
      t.date :publish_date

      t.timestamps
    end

    add_index :posts, :title, unique: true
    add_index :posts, :permalink, unique: true
    add_index :posts, :published
  end
end
