# frozen_string_literal: true

module Queries
  module Comments
    # Query to list comments with optional filters.
    class ListComments < Queries::Base
      type [Types::CommentType], null: false

      argument :filter, Queries::Objects::Comments::Filter, required: false

      def resolve(filter: nil)
        result = CommentManager::CommentLister.call(
          ability: current_ability,
          active: filter&.active
        )
        return [] unless result.success?

        result.payload.to_a
      end
    end
  end
end
