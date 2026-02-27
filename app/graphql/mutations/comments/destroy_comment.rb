# frozen_string_literal: true

module Mutations
  module Comments
    # Mutation to destroy a comment.
    class DestroyComment < Mutations::Base
      graphql_name 'DestroyComment'

      argument :id, ID, required: true

      field :comment, Types::CommentType, null: true
      field :errors, [String], null: false

      def resolve(id:)
        comment = Comment.find_by(id: id.to_i, account_id: current_account.id)
        raise_validation_error!('Comment not found', attribute: 'id') unless comment

        current_ability.authorize!(:destroy, comment)

        result = CommentManager::CommentDestructor.call(
          account: current_account,
          user: current_user,
          id: id.to_i
        )
        build_comment_response(result)
      end
    end
  end
end
