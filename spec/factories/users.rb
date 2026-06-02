# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    username { Faker::Internet.unique.username(specifier: 5..15, separators: %w[_ -]) }
    password { 'password123' }
    password_confirmation { 'password123' }
    confirmed_at { Time.current }
  end
end
