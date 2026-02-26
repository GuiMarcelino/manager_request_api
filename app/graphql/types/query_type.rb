# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :list_requests, [Types::RequestType], null: false, description: "List requests for current account with optional filters." do
      argument :status, String, required: false
      argument :category_id, ID, required: false
    end

    def list_requests(status: nil, category_id: nil)
      account = context[:current_account]
      return [] unless account

      scope = Request.where(account_id: account.id)
      scope = scope.where(status: status) if status.present?
      scope = scope.where(category_id: category_id) if category_id.present?
      scope.includes(:user, :category, :comments)
    end
  end
end
