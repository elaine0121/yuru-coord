class Outfit < ApplicationRecord
  belongs_to :user
  has_many :outfit_clothing_items, dependent: :destroy
  has_many :clothing_items, through: :outfit_clothing_items

  validates :scheduled_date, presence: true
  validates :scheduled_date, uniqueness: { scope: :user_id, message: "は1日1件までです" }
end
