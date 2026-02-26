# frozen_string_literal: true

module Mutations
  class SubmitRequest < BaseMutation
    argument :id, ID, required: true

    field :request, Types::RequestType, null: true
    field :errors, [String], null: false

    def resolve(id:)
      result = RequestManager::RequestSubmitter.call(account: current_account, id: id.to_i)
      result.success? ? { request: result.payload, errors: [] } : { request: nil, errors: [result.errors[:message]].compact }
    end
  end
end
