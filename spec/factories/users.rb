# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    account
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    role { :viewer }
  end
end
