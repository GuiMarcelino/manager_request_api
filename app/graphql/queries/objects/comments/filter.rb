# frozen_string_literal: true

module Queries
  module Objects
    module Comments
      # Input type for filtering comments.
      class Filter < Types::BaseInputObject
        graphql_name 'CommentFilter'

        argument :active, Boolean, required: false
      end
    end
  end
end
