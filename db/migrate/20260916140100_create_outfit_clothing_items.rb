class CreateOutfitClothingItems < ActiveRecord::Migration[7.2]
  def change
    create_table :outfit_clothing_items do |t|
      t.references :outfit, null: false, foreign_key: true
      t.references :clothing_item, null: false, foreign_key: true

      t.timestamps
    end

    add_index :outfit_clothing_items, [:outfit_id, :clothing_item_id], unique: true, name: "index_outfit_clothing_items_on_outfit_and_clothing_item"
  end
end
