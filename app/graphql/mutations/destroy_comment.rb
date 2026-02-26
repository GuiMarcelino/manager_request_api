# frozen_string_literal: true

module Mutations
  class DestroyComment < BaseMutation
    argument :id, ID, required: true

    field :comment, Types::CommentType, null: true
    field :errors, [String], null: false

    def resolve(id:)
      result = CommentManager::CommentDestructor.call(account: current_account, user: current_user, id: id.to_i)
      result.success? ? { comment: result.payload, errors: [] } : { comment: nil, errors: [result.errors[:message]].compact }
    end
  end
end
