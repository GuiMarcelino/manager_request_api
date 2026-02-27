# frozen_string_literal: true

module Queries
  module Concerns
    module Scopable
      extend ActiveSupport::Concern
      def scoped_by(scope, filter)
        return scope if filter.blank?

        filter_hash = filter.to_h.transform_keys(&:to_sym)
        filter_hash.each do |key, value|
          next if value.blank? && value != false

          scope_name = "by_#{key}"
          next unless scope.respond_to?(scope_name)

          scope = scope.public_send(scope_name, value)
        end
        scope
      end
    end
  end
end
