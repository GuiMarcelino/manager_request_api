# frozen_string_literal: true

module Mutations
  module Requests
    class ApproveRequest < Mutations::Base
      graphql_name "ApproveRequest"

      argument :id, ID, required: true

      field :request, Types::RequestType, null: true
      field :errors, [String], null: false

      def resolve(id:)
        result = RequestManager::RequestApprover.call(
          account: current_account,
          user: current_user,
          id: id.to_i
        )
        build_request_response(result)
      end
    end
  end
end
