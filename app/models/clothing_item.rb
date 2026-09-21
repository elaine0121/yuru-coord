class ClothingItem < ApplicationRecord
  belongs_to :user
  belongs_to :category
  has_many :outfit_clothing_items, dependent: :destroy
  has_many :outfits, through: :outfit_clothing_items

  enum :suitable_season, { spring: 0, summer: 1, autumn: 2, winter: 3, all_season: 4 }

  SUITABLE_SEASON_LABELS = {
    spring: "春", summer: "夏", autumn: "秋", winter: "冬", all_season: "通年"
  }.freeze

  validates :kind, presence: true

  def in_use?
    outfit_clothing_items.exists?
  end
end
