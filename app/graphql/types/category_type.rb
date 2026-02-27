# frozen_string_literal: true

module Types
  # GraphQL type for Category model.
  class CategoryType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :active, Boolean, null: false
  end
end
