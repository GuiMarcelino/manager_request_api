# frozen_string_literal: true

module Types
  # Root query type containing all query fields.
  class QueryType < Types::BaseObject
    field :list_requests, [Types::RequestType], null: false, resolver: Queries::Requests::ListRequests

    field :list_comments, [Types::CommentType], null: false, resolver: Queries::Comments::ListComments
  end
end
