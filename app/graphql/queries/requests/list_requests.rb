# frozen_string_literal: true

module Queries
  module Requests
    class ListRequests < Queries::Base
      include Queries::Concerns::Scopable

      type [Types::RequestType], null: false

      argument :filter, Queries::Objects::Requests::Filter, required: false

      def resolve(filter: nil)
        scope = initial_scope(filter)
        scope = scoped_by(scope, filter)
        scope.includes(:user, :category, :comments)
      end

      private

      def initial_scope(filter)
        scope = Request.all
        return scope unless current_account && (filter.blank? || filter.account_id.blank?)

        scope.by_account_id(current_account.id)
      end
    end
  end
end
