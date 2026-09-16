FactoryBot.define do
  factory :outfit do
    association :user
    situation { 0 }
    scheduled_date { Date.tomorrow }
  end
end
