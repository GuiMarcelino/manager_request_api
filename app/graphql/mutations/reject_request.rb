# frozen_string_literal: true

module Mutations
  class RejectRequest < BaseMutation
    argument :id, ID, required: true
    argument :rejected_reason, String, required: true

    field :request, Types::RequestType, null: true
    field :errors, [String], null: false

    def resolve(id:, rejected_reason:)
      result = RequestManager::RequestRejector.call(
        account: current_account,
        id: id.to_i,
        rejected_reason: rejected_reason
      )
      result.success? ? { request: result.payload, errors: [] } : { request: nil, errors: [result.errors[:message]].compact }
    end
  end
end
