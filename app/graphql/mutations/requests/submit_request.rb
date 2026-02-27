# frozen_string_literal: true

module Mutations
  module Requests
    class SubmitRequest < Mutations::Base
      graphql_name "SubmitRequest"

      argument :id, ID, required: true

      field :request, Types::RequestType, null: true
      field :errors, [String], null: false

      def resolve(id:)
        result = RequestManager::RequestSubmitter.call(
          account: current_account,
          id: id.to_i
        )
        build_request_response(result)
      end
    end
  end
end
