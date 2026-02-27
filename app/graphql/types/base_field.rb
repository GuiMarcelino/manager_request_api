# frozen_string_literal: true

module Types
  # Base class for GraphQL field definitions.
  class BaseField < GraphQL::Schema::Field
    argument_class Types::BaseArgument
  end
end
