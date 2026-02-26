# frozen_string_literal: true

module RequestManager
  class RequestSubmitter < ApplicationService
    def initialize(params)
      @account = params.fetch(:account)
      @id = params.fetch(:id)
    end

    def call
      return not_found_error("Request") unless request
      return invalid_status_error unless request.draft?

      submit_request
    end

    private

    def request
      @request ||= Request.find_by(id: @id, account_id: @account.id)
    end

    def invalid_status_error
      service_result(success: false, errors: { message: "Request is not in draft status", code: 422 })
    end

    def submit_request
      request.update!(status: :pending_approval, submitted_at: Time.current)

      service_result(success: true, payload: request)
    end
  end
end
