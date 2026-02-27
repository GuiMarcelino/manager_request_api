# frozen_string_literal: true

module Mutations
  class Base < GraphQL::Schema::Mutation
    argument_class Types::BaseArgument
    field_class Types::BaseField
    object_class Types::BaseObject

    def current_account
      context[:current_account]
    end

    def current_user
      context[:current_user]
    end

    private

    def raise_validation_error!(message, attribute: nil)
      ext = { code: "VALIDATION_ERROR", http_status: 422 }
      ext[:attribute] = attribute if attribute.present?
      raise GraphQL::ExecutionError.new(message, extensions: ext)
    end

    def extract_attribute_from_message(message)
      return nil if message.blank?

      m = message.to_s.match(/Missing required param: (\w+)/)
      m ? m[1] : nil
    end

    def build_request_response(result)
      return { request: result.payload, errors: [] } if result.success?

      raise_validation_error!(
        result.errors[:message].to_s.presence || "Validation failed",
        attribute: extract_attribute_from_message(result.errors[:message])
      )
    end

    def build_comment_response(result)
      return { comment: result.payload, errors: [] } if result.success?

      raise_validation_error!(
        result.errors[:message].to_s.presence || "Validation failed",
        attribute: extract_attribute_from_message(result.errors[:message])
      )
    end
  end
end
