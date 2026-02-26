# frozen_string_literal: true

module RequestManager
  class RequestCreator < ApplicationService
    def initialize(params)
      @account = params[:account]
      @user = params[:user]
      @title = params[:title]
      @category = params[:category]
      @description = params[:description]
    end

    def call
      return missing_service_parameter(:account) if @account.blank?
      return missing_service_parameter(:user) if @user.blank?
      return missing_service_parameter(:title) if @title.blank?
      return missing_service_parameter(:category) if @category.blank?
      return error_user_not_in_account unless user_belongs_to_account?
      return error_category_not_in_account unless category_belongs_to_account?

      create_request
    end

    private

    def user_belongs_to_account?
      @user.account_id == @account.id
    end

    def category_belongs_to_account?
      @category.account_id == @account.id
    end

    def error_user_not_in_account
      service_result(success: false, errors: { message: "User does not belong to account", code: 422 })
    end

    def error_category_not_in_account
      service_result(success: false, errors: { message: "Category does not belong to account", code: 422 })
    end

    def create_request
      request = Request.new(
        account: @account,
        user: @user,
        category: @category,
        title: @title,
        description: @description,
        status: :draft
      )
      return service_result(success: false, errors: validation_errors(request)) unless request.save

      service_result(success: true, payload: request)
    end

    def validation_errors(request)
      { message: request.errors.full_messages.join(", "), code: 422 }
    end
  end
end
