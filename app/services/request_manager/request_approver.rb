# frozen_string_literal: true

module RequestManager
  class RequestApprover < ApplicationService
    def initialize(params)
      @account = params.fetch(:account)
      @user = params.fetch(:user)
      @id = params.fetch(:id)
    end

    def call
      return not_found_error("Request") unless request
      return forbidden_error unless @user.admin?

      request_decided_at
    end

    private

    def request
      @request ||= Request.find_by(id: @id, account_id: @account.id)
    end

    def forbidden_error
      service_result(success: false, errors: { message: "Only admin can approve", code: 403 })
    end

    def request_decided_at
      request.update!(decided_at: Time.current, status: :approved)
      service_result(success: true, payload: request)
    end
  end
end
