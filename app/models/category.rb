class Category < ApplicationRecord
  has_many :clothing_items

  validates :name, presence: true, uniqueness: true
  validates :sort_order, presence: true, numericality: { only_integer: true }
end
