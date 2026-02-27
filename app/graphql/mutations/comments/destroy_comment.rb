# frozen_string_literal: true

module Mutations
  module Comments
    class DestroyComment < Mutations::Base
      graphql_name "DestroyComment"

      argument :id, ID, required: true

      field :comment, Types::CommentType, null: true
      field :errors, [String], null: false

      def resolve(id:)
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
