# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_09_21_050650) do
  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.integer "sort_order", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "clothing_items", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "category_id", null: false
    t.string "kind", null: false
    t.string "color"
    t.text "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "suitable_season"
    t.index ["category_id"], name: "index_clothing_items_on_category_id"
    t.index ["user_id"], name: "index_clothing_items_on_user_id"
  end

  create_table "outfit_clothing_items", force: :cascade do |t|
    t.integer "outfit_id", null: false
    t.integer "clothing_item_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["clothing_item_id"], name: "index_outfit_clothing_items_on_clothing_item_id"
    t.index ["outfit_id", "clothing_item_id"], name: "index_outfit_clothing_items_on_outfit_and_clothing_item", unique: true
    t.index ["outfit_id"], name: "index_outfit_clothing_items_on_outfit_id"
  end

  create_table "outfits", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name"
    t.integer "situation", default: 0, null: false
    t.date "scheduled_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "scheduled_date"], name: "index_outfits_on_user_id_and_scheduled_date", unique: true
    t.index ["user_id"], name: "index_outfits_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "clothing_items", "categories"
  add_foreign_key "clothing_items", "users"
  add_foreign_key "outfit_clothing_items", "clothing_items"
  add_foreign_key "outfit_clothing_items", "outfits"
  add_foreign_key "outfits", "users"
end
