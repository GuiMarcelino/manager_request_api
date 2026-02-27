# frozen_string_literal: true

module Types
  class CommentType < Types::BaseObject
    field :id, ID, null: false
    field :body, String, null: false
    field :active, Boolean, null: false
    field :request, Types::RequestType, null: false
    field :user, Types::UserType, null: false

    def request
      load_association(object, :request)
    end

    def user
      load_association(object, :user)
    end
  end
end
