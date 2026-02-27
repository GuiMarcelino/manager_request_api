# frozen_string_literal: true

module Types
  class RequestType < Types::BaseObject
    field :id, ID, null: false
    field :title, String, null: false
    field :description, String, null: true
    field :status, String, null: false
    field :rejected_reason, String, null: true
    field :submitted_at, GraphQL::Types::ISO8601DateTime, null: true
    field :decided_at, GraphQL::Types::ISO8601DateTime, null: true
    field :user, Types::UserType, null: false
    field :category, Types::CategoryType, null: false
    field :comments, [Types::CommentType], null: false

    def user
      object.user
    end

    def category
      object.category
    end

    def comments
      object.comments.active
    end
  end
end
