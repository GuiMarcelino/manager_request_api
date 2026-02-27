# frozen_string_literal: true

# Represents a request category within an account.
class Category < ApplicationRecord
  belongs_to :account, inverse_of: :categories
  has_many :requests, inverse_of: :category, dependent: :restrict_with_error

  validates :name, presence: true
  validates :active, inclusion: { in: [true, false] }
end
