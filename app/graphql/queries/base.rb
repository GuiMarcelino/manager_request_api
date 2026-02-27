# frozen_string_literal: true

module Queries
  class Base < GraphQL::Schema::Resolver
    private

    def current_account
      context[:current_account]
    end

    def current_user
      context[:current_user]
    end
  end
end
