# frozen_string_literal: true

# Controller for GraphQL API requests.
class GraphqlController < ApplicationController
  # If accessing from outside this domain, nullify the session
  # This allows for outside API access while preventing CSRF attacks,
  # but you'll have to authenticate your user separately
  # protect_from_forgery with: :null_session

  def execute
    result = execute_graphql
    render json: result, status: graphql_http_status(result)
  rescue CanCan::AccessDenied => e
    render_access_denied(e)
  rescue StandardError => e
    raise e unless Rails.env.development?

    handle_error_in_development(e)
  end

  private

  def execute_graphql
    ManagerRequestApiSchema.execute(
      params[:query],
      variables: prepare_variables(params[:variables]),
      context: graphql_context,
      operation_name: params[:operationName]
    )
  end

  def graphql_context
    {
      current_user: default_user,
      current_account: default_account,
      current_ability: Ability.new(default_user)
    }
  end

  def render_access_denied(exception)
    render json: {
      errors: [{ message: exception.message, extensions: { code: 'FORBIDDEN', http_status: 403 } }],
      data: nil
    }, status: :forbidden
  end

  def default_user
    @default_user ||= resolve_user_from_request
  end

  def default_account
    @default_account ||= resolve_account_from_request
  end

  def resolve_user_from_request
    user_id = request.headers['X-User-Id']
    return User.first if user_id.blank?

    User.find_by(id: user_id) || User.first
  end

  def resolve_account_from_request
    account_id = request.headers['X-Account-Id']
    return Account.first if account_id.blank?

    Account.find_by(id: account_id) || Account.first
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
    errors = hash['errors']
    return 200 if errors.blank? || !errors.is_a?(Array)

    first = errors.first
    return 200 unless first.is_a?(Hash)

    first.dig('extensions', 'http_status') || 422
  end

  def handle_error_in_development(exception)
    logger.error exception.message
    logger.error exception.backtrace.join("\n")

    render json: { errors: [{ message: exception.message, backtrace: exception.backtrace }], data: {} },
           status: :internal_server_error
  end
end
