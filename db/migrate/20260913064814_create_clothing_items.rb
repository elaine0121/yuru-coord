class CreateClothingItems < ActiveRecord::Migration[7.2]
  def change
    create_table :clothing_items do |t|
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.string :kind, null: false
      t.string :color
      t.text :memo

      t.timestamps
    end
  end
end
