# frozen_string_literal: true

class User < ApplicationRecord
  # Constants
  ROLES = %i[
    viewer
    editor
    admin
  ].freeze

  # Enumerize
  extend Enumerize

  enumerize :role, in: ROLES, default: :viewer, predicates: true

  belongs_to :account, inverse_of: :users
  has_many :requests, inverse_of: :user, dependent: :restrict_with_error
  has_many :comments, inverse_of: :user, dependent: :restrict_with_error

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { scope: :account_id }
end
