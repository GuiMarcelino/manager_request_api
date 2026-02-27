# frozen_string_literal: true

module Mutations
  module Requests
    class RejectRequest < Mutations::Base
      graphql_name "RejectRequest"

      argument :id, ID, required: true
      argument :rejected_reason, String, required: true

      field :request, Types::RequestType, null: true
      field :errors, [String], null: false

      def resolve(id:, rejected_reason:)
        result = RequestManager::RequestRejector.call(
          account: current_account,
          id: id.to_i,
          rejected_reason: rejected_reason
        )
        build_request_response(result)
      end
    end
  end
end
