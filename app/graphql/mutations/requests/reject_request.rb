# frozen_string_literal: true

module Mutations
  module Requests
    # Mutation to reject a pending request.
    class RejectRequest < Mutations::Base
      graphql_name 'RejectRequest'

      argument :id, ID, required: true
      argument :rejected_reason, String, required: true

      field :request, Types::RequestType, null: true
      field :errors, [String], null: false

      def resolve(id:, rejected_reason:)
        request = Request.find_by(id: id.to_i, account_id: current_account.id)
        raise_validation_error!('Request not found', attribute: 'id') unless request

        current_ability.authorize!(:reject, request)

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
