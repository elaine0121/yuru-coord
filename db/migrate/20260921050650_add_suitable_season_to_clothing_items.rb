class AddSuitableSeasonToClothingItems < ActiveRecord::Migration[7.2]
  def change
    add_column :clothing_items, :suitable_season, :integer
  end
end
