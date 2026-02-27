# frozen_string_literal: true

module Mutations
  module Requests
    # Mutation to create a new request.
    class CreateRequest < Mutations::Base
      graphql_name 'CreateRequest'

      argument :title, String, required: true
      argument :category_id, ID, required: true
      argument :description, String, required: false

      field :request, Types::RequestType, null: true
      field :errors, [String], null: false

      def resolve(title:, category_id:, description: nil)
        category = Category.find_by(id: category_id, account_id: current_account.id)

        result = RequestManager::RequestCreator.call(
          account: current_account,
          user: current_user,
          title: title,
          category: category,
          description: description
        )
        build_request_response(result)
      end
    end
  end
end
