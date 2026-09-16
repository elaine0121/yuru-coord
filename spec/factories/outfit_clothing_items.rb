FactoryBot.define do
  factory :outfit_clothing_item do
    association :outfit
    association :clothing_item
  end
end
