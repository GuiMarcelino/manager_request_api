# frozen_string_literal: true

module Queries
  module Objects
    module Requests
      # Input type for filtering requests.
      class Filter < Types::BaseInputObject
        graphql_name 'RequestFilter'

        argument :account_id, ID, required: true
        argument :status, String, required: false
        argument :category_id, ID, required: false
      end
    end
  end
end
