# frozen_string_literal: true

# Result object for service responses (Struct avoids ostruct dependency on Ruby 3.2).
ServiceResult = Struct.new(:success?, :payload, :errors, keyword_init: true)

class ApplicationService
  def self.call(params = {})
    new(params).call
  end

  private

  def service_result(success:, payload: nil, errors: nil)
    ServiceResult.new(success?: success, payload: payload, errors: errors)
  end

  def not_found_error(entity)
    service_result(success: false, errors: { message: "#{entity} not found", code: 404 })
  end

  def missing_service_parameter(param)
    service_result(success: false, errors: { message: "Missing required param: #{param}", code: 422 })
  end
end
