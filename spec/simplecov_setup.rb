# frozen_string_literal: true

require "simplecov"
SimpleCov.start "rails" do
  minimum_coverage 90
  add_filter "/spec/"
  add_filter "/config/"
  add_filter "/vendor/"
  add_filter "app/controllers/application_controller.rb"
  add_filter "app/mailers/application_mailer.rb"
  add_filter "app/jobs/application_job.rb"
  add_filter "app/models/application_record.rb"
  add_filter "app/services/application_service.rb"
  add_filter "app/graphql/manager_request_api_schema.rb"
  add_filter "app/graphql/types/base_interface.rb"
  add_filter "app/graphql/types/base_union.rb"
  add_filter "app/graphql/types/base_edge.rb"
  add_filter "app/graphql/types/base_connection.rb"
  add_filter "app/graphql/types/base_scalar.rb"
  add_filter "app/graphql/types/base_enum.rb"
  add_filter "app/graphql/types/base_argument.rb"
  add_filter "app/graphql/types/base_field.rb"
  add_filter "app/graphql/types/base_input_object.rb"
  add_filter "app/graphql/types/node_type.rb"
  add_filter "app/graphql/resolvers/base_resolver.rb"
end
