# frozen_string_literal: true

FactoryBot.define do
  factory :comment do
    account
    request { create(:request, account: account) }
    user { create(:user, account: account) }
    body { Faker::Lorem.paragraph }
  end
end
