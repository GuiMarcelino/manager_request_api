# frozen_string_literal: true

module Mutations
  class Mutation < Types::BaseObject
    field :create_request, mutation: Mutations::Requests::CreateRequest
    field :submit_request, mutation: Mutations::Requests::SubmitRequest
    field :approve_request, mutation: Mutations::Requests::ApproveRequest
    field :reject_request, mutation: Mutations::Requests::RejectRequest
    field :create_comment, mutation: Mutations::Comments::CreateComment
    field :destroy_comment, mutation: Mutations::Comments::DestroyComment
  end
end
