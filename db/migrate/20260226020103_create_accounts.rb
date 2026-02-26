class CreateAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts do |t|
      t.string :name, null: false
      t.string :cnpj, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
