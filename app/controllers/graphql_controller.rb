# frozen_string_literal: true

class GraphqlController < ApplicationController
  # If accessing from outside this domain, nullify the session
  # This allows for outside API access while preventing CSRF attacks,
  # but you'll have to authenticate your user separately
  # protect_from_forgery with: :null_session

  def execute
    variables = prepare_variables(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]
    context = {
      current_user: default_user,
      current_account: default_account
    }
    result = ManagerRequestApiSchema.execute(
      query,
      variables: variables,
      context: context,
      operation_name: operation_name
    )
    status = graphql_http_status(result)
    render json: result, status: status
  rescue StandardError => e
    raise e unless Rails.env.development?
    handle_error_in_development(e)
  end

  private

  def default_user
    @default_user ||= User.first
  end

  def default_account
    @default_account ||= Account.first
  end

  # Handle variables in form data, JSON body, or a blank value
  def prepare_variables(variables_param)
    case variables_param
    when String
      return {} if variables_param.blank?

      JSON.parse(variables_param) || {}
    when Hash
      variables_param
    when ActionController::Parameters
      variables_param.to_unsafe_hash # GraphQL-Ruby will validate name and type of incoming variables.
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{variables_param}"
    end
  end

  def graphql_http_status(result)
    hash = result.respond_to?(:to_h) ? result.to_h : {}
    errors = hash["errors"]
    return 200 if errors.blank? || !errors.is_a?(Array)

    first = errors.first
    return 200 unless first.is_a?(Hash)

    first.dig("extensions", "http_status") || 422
  end

  def handle_error_in_development(e)
    logger.error e.message
    logger.error e.backtrace.join("\n")

    render json: { errors: [{ message: e.message, backtrace: e.backtrace }], data: {} }, status: 500
  end
end
