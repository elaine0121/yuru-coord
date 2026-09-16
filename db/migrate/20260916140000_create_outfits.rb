class CreateOutfits < ActiveRecord::Migration[7.2]
  def change
    create_table :outfits do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.integer :situation, null: false, default: 0
      t.date :scheduled_date, null: false

      t.timestamps
    end

    add_index :outfits, [:user_id, :scheduled_date], unique: true, name: "index_outfits_on_user_id_and_scheduled_date"
  end
end
