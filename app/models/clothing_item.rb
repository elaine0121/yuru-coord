class ClothingItem < ApplicationRecord
  belongs_to :user
  belongs_to :category

  validates :kind, presence: true

  # TODO: outfits（コーデ）機能実装時に、outfit_clothing_items での使用有無を判定する
  # 例）OUTFIT_TABLE ができたら以下を実装する:
  # def in_use?
  #   outfit_clothing_items.exists?
  # end
  def in_use?
    false
  end
end
