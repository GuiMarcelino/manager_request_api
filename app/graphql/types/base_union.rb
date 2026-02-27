# frozen_string_literal: true

module Types
  # Base class for GraphQL union types.
  class BaseUnion < GraphQL::Schema::Union
    edge_type_class(Types::BaseEdge)
    connection_type_class(Types::BaseConnection)
  end
end
