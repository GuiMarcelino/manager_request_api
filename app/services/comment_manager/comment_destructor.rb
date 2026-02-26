# frozen_string_literal: true

module CommentManager
  class CommentDestructor < ApplicationService
    def initialize(params)
      @account = params.fetch(:account)
      @user = params.fetch(:user)
      @id = params.fetch(:id)
    end

    def call
      return not_found_error("Comment") unless comment
      return forbidden_error unless author_or_admin?

      destroy_comment
    end

    private

    def comment
      @comment ||= Comment.find_by(id: @id, account_id: @account.id)
    end

    def author_or_admin?
      comment.user_id == @user.id || @user.admin?
    end

    def forbidden_error
      service_result(success: false, errors: { message: "Only author or admin can remove comment", code: 403 })
    end

    def destroy_comment
      comment.destroy!
      service_result(success: true, payload: comment)
    end
  end
end
