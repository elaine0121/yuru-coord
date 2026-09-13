FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "カテゴリ#{n}" }
    sequence(:sort_order) { |n| n }
  end
end
