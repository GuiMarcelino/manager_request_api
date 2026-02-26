# frozen_string_literal: true

class Account < ApplicationRecord
  has_many :users, inverse_of: :account, dependent: :restrict_with_error
  has_many :categories, inverse_of: :account, dependent: :restrict_with_error
  has_many :requests, inverse_of: :account, dependent: :restrict_with_error
  has_many :comments, inverse_of: :account, dependent: :restrict_with_error

  validates :name, presence: true
  validates :cnpj, presence: true
  validate :cnpj_must_be_valid

  private

  def cnpj_must_be_valid
    return if CNPJ.valid?(cnpj)

    errors.add(:cnpj, :invalid)
  end
end
