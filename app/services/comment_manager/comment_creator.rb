# frozen_string_literal: true

module CommentManager
  class CommentCreator < ApplicationService
    def initialize(params)
      @account = params[:account]
      @request = params[:request]
      @user = params[:user]
      @body = params[:body]
    end

    def call
      return error_request_not_in_account unless request_belongs_to_account?

      create_comment
    end

    private

    def request_belongs_to_account?
      @request.account_id == @account.id
    end

    def error_request_not_in_account
      service_result(success: false, errors: { message: "Request does not belong to account", code: 422 })
    end

    def create_comment
      comment = Comment.new(
        account: @account,
        request: @request,
        user: @user,
        body: @body
      )
      return service_result(success: false, errors: validation_errors(comment)) unless comment.save

      service_result(success: true, payload: comment)
    end

    def validation_errors(comment)
      { message: comment.errors.full_messages.join(", "), code: 422 }
    end
  end
end
