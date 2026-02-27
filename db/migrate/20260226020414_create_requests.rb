# frozen_string_literal: true

class CreateRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :requests do |t|
      t.references :account, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.string :status, null: false, default: "draft"
      t.text :rejected_reason
      t.datetime :submitted_at
      t.datetime :decided_at

      t.timestamps
    end
  end
end
