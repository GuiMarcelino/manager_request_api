# frozen_string_literal: true

module Types
  # Base class for GraphQL object types.
  class BaseObject < GraphQL::Schema::Object
    edge_type_class(Types::BaseEdge)
    connection_type_class(Types::BaseConnection)
    field_class Types::BaseField

    def load_association(record, association, scope = nil)
      source = GraphQL::Dataloader::ActiveRecordAssociationSource
      if scope
        context.dataloader.with(source, association, scope).load(record)
      else
        context.dataloader.with(source, association).load(record)
      end
    end
  end
end
