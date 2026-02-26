# frozen_string_literal: true

FactoryBot.define do
  factory :category do
    account
    name { Faker::Commerce.department }
    active { true }
  end
end
