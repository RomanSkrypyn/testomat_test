# frozen_string_literal: true

FactoryBot.define do
  factory :notification do
    association :comment
    association :mentioned_user, factory: :user
    read { false }
  end
end
