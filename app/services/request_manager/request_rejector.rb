# frozen_string_literal: true

module RequestManager
  class RequestRejector < ApplicationService
    def initialize(params)
      @account = params.fetch(:account)
      @id = params.fetch(:id)
      @rejected_reason = params[:rejected_reason]
    end

    def call
      return not_found_error("Request") unless request
      return missing_service_parameter(:rejected_reason) if @rejected_reason.blank?

      reject_request
    end

    private

    def request
      @request ||= Request.find_by(id: @id, account_id: @account.id)
    end

    def reject_request
      request.update!(rejected_reason: @rejected_reason, decided_at: Time.current)
      service_result(success: true, payload: request)
    end
  end
end
