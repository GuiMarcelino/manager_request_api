# frozen_string_literal: true

class Request < ApplicationRecord
  # Constants
  STATUSES = %i[
    draft
    pending_approval
    approved
    rejected
  ].freeze

  # Enumerize
  extend Enumerize

  enumerize :status, in: STATUSES, default: :draft, predicates: true

  belongs_to :account, inverse_of: :requests
  belongs_to :user, inverse_of: :requests
  belongs_to :category, inverse_of: :requests

  has_many :comments, inverse_of: :request, dependent: :restrict_with_error

  validates :title, presence: true
end
