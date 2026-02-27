# frozen_string_literal: true

module Queries
  module Requests
    class ListRequests < Queries::Base
      type [Types::RequestType], null: false

      argument :status, String, required: false
      argument :category_id, ID, required: false
      argument :account_id, ID, required: false

      def resolve(status: nil, category_id: nil, account_id: nil)
        scope = base_scope(account_id)
        scope = scope.pending if status.to_s == "pending_approval"
        scope = scope.where(status: status) if status.present? && status != "pending_approval"
        scope = scope.where(category_id: category_id) if category_id.present?
        scope.includes(:user, :category, :comments)
      end

      private

      def base_scope(account_id)
        if account_id.present?
          Request.where(account_id: account_id)
        else
          account = current_account
          account ? Request.by_account(account) : Request.all
        end
      end
    end
  end
end
