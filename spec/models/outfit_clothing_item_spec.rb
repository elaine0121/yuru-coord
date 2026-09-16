require 'rails_helper'

RSpec.describe OutfitClothingItem, type: :model do
  describe 'バリデーション' do
    it '有効な属性なら登録できる' do
      outfit_clothing_item = build(:outfit_clothing_item)
      expect(outfit_clothing_item).to be_valid
    end

    it 'outfitが無ければ無効' do
      outfit_clothing_item = build(:outfit_clothing_item, outfit: nil)
      expect(outfit_clothing_item).to be_invalid
    end

    it 'clothing_itemが無ければ無効' do
      outfit_clothing_item = build(:outfit_clothing_item, clothing_item: nil)
      expect(outfit_clothing_item).to be_invalid
    end
  end

  describe '同一outfit内での重複アイテム防止' do
    it '同じコーデに同じ洋服を重複登録できない' do
      outfit = create(:outfit)
      clothing_item = create(:clothing_item, user: outfit.user)
      create(:outfit_clothing_item, outfit: outfit, clothing_item: clothing_item)

      duplicate = build(:outfit_clothing_item, outfit: outfit, clothing_item: clothing_item)
      expect(duplicate).to be_invalid
      expect(duplicate.errors[:clothing_item_id]).to be_present
    end

    it '別のコーデなら同じ洋服を登録できる' do
      outfit_a = create(:outfit)
      outfit_b = create(:outfit, user: outfit_a.user, scheduled_date: Date.new(2026, 10, 2))
      clothing_item = create(:clothing_item, user: outfit_a.user)
      create(:outfit_clothing_item, outfit: outfit_a, clothing_item: clothing_item)

      other = build(:outfit_clothing_item, outfit: outfit_b, clothing_item: clothing_item)
      expect(other).to be_valid
    end
  end
end
