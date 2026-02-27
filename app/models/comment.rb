# frozen_string_literal: true

# Represents a comment on a request.
class Comment < ApplicationRecord
  belongs_to :account, inverse_of: :comments
  belongs_to :request, inverse_of: :comments
  belongs_to :user, inverse_of: :comments

  validates :body, presence: true

  scope :by_active, ->(active) { where(active: active) }
end
