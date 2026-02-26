class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.references :account, null: false, foreign_key: true
      t.string :name, null: false
      t.string :email, null: false
      t.string :role, null: false, default: "viewer"

      t.timestamps
    end
  end
end
