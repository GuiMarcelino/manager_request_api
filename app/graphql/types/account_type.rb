# frozen_string_literal: true

module Types
  # GraphQL type for Account model.
  class AccountType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :cnpj, String, null: false
    field :active, Boolean, null: false
  end
end
