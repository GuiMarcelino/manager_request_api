# frozen_string_literal: true

module Queries
  module Requests
    # Query to list requests with optional filters.
    class ListRequests < Queries::Base
      type [Types::RequestType], null: false

      argument :filter, Queries::Objects::Requests::Filter, required: true

      def resolve(filter:)
        result = RequestManager::RequestLister.call(
          ability: current_ability,
          account_id: filter.account_id,
          status: filter.status,
          category_id: filter.category_id
        )
        return [] unless result.success?

        result.payload.to_a
      end
    end
  end
end
