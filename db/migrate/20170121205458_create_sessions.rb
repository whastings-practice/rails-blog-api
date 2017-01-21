class CreateSessions < ActiveRecord::Migration[5.0]
  def change
    create_table :sessions do |t|
      t.string :token, null: false
      t.references :user, foreign_key: true, null: false

      t.timestamps
    end

    add_index :sessions, :token, unique: true
  end
end
