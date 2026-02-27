# frozen_string_literal: true

FactoryBot.define do
  factory :comment do
    account
    request { association :request, account: account }
    user { association :user, account: account }
    body { Faker::Lorem.paragraph }
  end
end
