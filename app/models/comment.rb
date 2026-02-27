# frozen_string_literal: true

# Represents a comment on a request.
class Comment < ApplicationRecord
  belongs_to :account, inverse_of: :comments
  belongs_to :request, inverse_of: :comments
  belongs_to :user, inverse_of: :comments

  validates :body, presence: true

  scope :by_active, lambda { |active|
    if active.nil?
      all
    else
      (active ? where(active: true) : where(active: false))
    end
  }
end
