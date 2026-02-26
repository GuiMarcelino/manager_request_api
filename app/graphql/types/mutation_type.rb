# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :create_request, mutation: Mutations::CreateRequest
    field :submit_request, mutation: Mutations::SubmitRequest
    field :approve_request, mutation: Mutations::ApproveRequest
    field :reject_request, mutation: Mutations::RejectRequest
    field :create_comment, mutation: Mutations::CreateComment
    field :destroy_comment, mutation: Mutations::DestroyComment
  end
end
