class ClothingItem < ApplicationRecord
  belongs_to :user
  belongs_to :category
  has_many :outfit_clothing_items, dependent: :destroy
  has_many :outfits, through: :outfit_clothing_items

  validates :kind, presence: true

  def in_use?
    outfit_clothing_items.exists?
  end
end
