# frozen_string_literal: true

module Mutations
  module Comments
    # Mutation to create a new comment on a request.
    class CreateComment < Mutations::Base
      graphql_name 'CreateComment'

      argument :request_id, ID, required: true
      argument :body, String, required: true

      field :comment, Types::CommentType, null: true
      field :errors, [String], null: false

      def resolve(request_id:, body:)
        request = Request.find_by(id: request_id, account_id: current_account.id)
        raise_validation_error!('Request not found', attribute: 'requestId') unless request

        result = CommentManager::CommentCreator.call(
          account: current_account,
          request: request,
          user: current_user,
          body: body
        )
        build_comment_response(result)
      end
    end
  end
end
