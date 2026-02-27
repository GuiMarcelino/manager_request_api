# frozen_string_literal: true

module Mutations
  module Requests
    # Mutation to approve a pending request.
    class ApproveRequest < Mutations::Base
      graphql_name 'ApproveRequest'

      argument :id, ID, required: true

      field :request, Types::RequestType, null: true
      field :errors, [String], null: false

      def resolve(id:)
        request = Request.find_by(id: id.to_i, account_id: current_account.id)
        raise_validation_error!('Request not found', attribute: 'id') unless request

        current_ability.authorize!(:approve, request)

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
