# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :list_requests, [Types::RequestType], null: false,
      description: "List requests for current account with optional filters.",
      resolver: Queries::Requests::ListRequests
  end
end
