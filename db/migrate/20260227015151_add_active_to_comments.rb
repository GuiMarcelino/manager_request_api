class AddActiveToComments < ActiveRecord::Migration[8.1]
  def change
    add_column :comments, :active, :boolean, null: false, default: true
  end
end
