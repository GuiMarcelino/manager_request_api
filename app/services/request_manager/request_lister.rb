# frozen_string_literal: true

module RequestManager
  # Service to list and filter requests.
  class RequestLister < ApplicationService
    def initialize(params)
      super()
      @ability = params[:ability]
      @account_id = params[:account_id] || params[:account]&.id
      @status = params[:status]
      @category_id = params[:category_id] || params[:category]&.id
    end

    def call
      return missing_service_parameter(:account_id) if @account_id.blank?
      return missing_service_parameter(:ability) if @ability.blank?

      list_requests
    end

    private

    def list_requests
      scope = Request.accessible_by(@ability)
      scope = scope.by_account_id(@account_id)
      scope = scope.by_status(@status) if @status.present?
      scope = scope.by_category_id(@category_id) if @category_id.present?

      service_result(success: true, payload: scope)
    end
  end
end
