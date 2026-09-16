class OutfitClothingItem < ApplicationRecord
  belongs_to :outfit
  belongs_to :clothing_item

  validates :clothing_item_id, uniqueness: { scope: :outfit_id, message: "は同じコーデに重複登録できません" }
end
