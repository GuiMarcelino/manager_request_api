# frozen_string_literal: true

module Mutations
  class CreateComment < BaseMutation
    argument :request_id, ID, required: true
    argument :body, String, required: true

    field :comment, Types::CommentType, null: true
    field :errors, [String], null: false

    def resolve(request_id:, body:)
      request = Request.find_by(id: request_id, account_id: current_account.id)
      return { comment: nil, errors: ["Request not found"] } unless request

      result = CommentManager::CommentCreator.call(
        account: current_account,
        request: request,
        user: current_user,
        body: body
      )
      result.success? ? { comment: result.payload, errors: [] } : { comment: nil, errors: [result.errors[:message]].compact }
    end
  end
end
