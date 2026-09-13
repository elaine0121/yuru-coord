class ClothingItem < ApplicationRecord
  belongs_to :user
  belongs_to :category

  validates :kind, presence: true
end
