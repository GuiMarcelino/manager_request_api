# frozen_string_literal: true

FactoryBot.define do
  factory :request do
    account
    user { association :user, account: account }
    category { association :category, account: account }
    title { Faker::Lorem.sentence(word_count: 3) }
    description { Faker::Lorem.paragraph }
    status { :draft }
  end
end
