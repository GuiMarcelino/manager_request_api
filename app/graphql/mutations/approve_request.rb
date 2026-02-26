# frozen_string_literal: true

module Mutations
  class ApproveRequest < BaseMutation
    argument :id, ID, required: true

    field :request, Types::RequestType, null: true
    field :errors, [String], null: false

    def resolve(id:)
      result = RequestManager::RequestApprover.call(account: current_account, user: current_user, id: id.to_i)
      result.success? ? { request: result.payload, errors: [] } : { request: nil, errors: [result.errors[:message]].compact }
    end
  end
end
