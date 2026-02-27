# frozen_string_literal: true

module Queries
  module Objects
    module Requests
      class Filter < Types::BaseInputObject
        graphql_name "RequestFilter"

        argument :account_id, ID, required: false
        argument :status, String, required: false
        argument :category_id, ID, required: false
      end
    end
  end
end
