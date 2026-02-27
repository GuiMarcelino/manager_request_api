# frozen_string_literal: true

class Comment < ApplicationRecord
  belongs_to :account, inverse_of: :comments
  belongs_to :request, inverse_of: :comments
  belongs_to :user, inverse_of: :comments

  validates :body, presence: true

  scope :by_active, ->(active) { active.nil? ? all : (active ? where(active: true) : where(active: false)) }
end
