FactoryBot.define do
  factory :clothing_item do
    association :user
    association :category
    sequence(:kind) { |n| "Tシャツ#{n}" }
    color { "ホワイト" }
    memo { "定番の一枚" }
  end
end
