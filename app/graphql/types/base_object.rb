# frozen_string_literal: true

module Types
  class BaseObject < GraphQL::Schema::Object
    edge_type_class(Types::BaseEdge)
    connection_type_class(Types::BaseConnection)
    field_class Types::BaseField

    # Carrega associação via DataLoader para evitar N+1.
    # Para has_many com filtro, passe scope: Model.scope(...).
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
