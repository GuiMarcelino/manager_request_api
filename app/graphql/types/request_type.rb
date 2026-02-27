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
    field :comments, [Types::CommentType], null: false do
      argument :filter, Queries::Objects::Comments::Filter, required: false
    end

    def user
      object.user
    end

    def category
      object.category
    end

    def comments(filter: nil)
      scope = object.comments
      return scope.active if filter.blank?

      scope.by_active(filter.active)
    end
  end
end
