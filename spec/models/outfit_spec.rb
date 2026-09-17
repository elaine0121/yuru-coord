require 'rails_helper'

RSpec.describe Outfit, type: :model do
  describe 'バリデーション' do
    it '有効な属性なら登録できる' do
      outfit = build(:outfit)
      expect(outfit).to be_valid
    end

    it 'userが無ければ無効' do
      outfit = build(:outfit, user: nil)
      expect(outfit).to be_invalid
    end

    it 'scheduled_dateが空なら無効' do
      outfit = build(:outfit, scheduled_date: nil)
      expect(outfit).to be_invalid
    end
  end

  describe '同一ユーザー・同一日付の複合unique制約' do
    it '同じユーザーで同じ日付のコーデは重複登録できない' do
      user = create(:user)
      create(:outfit, user: user, scheduled_date: Date.new(2026, 10, 1))

      duplicate = build(:outfit, user: user, scheduled_date: Date.new(2026, 10, 1))
      expect(duplicate).to be_invalid
      expect(duplicate.errors[:scheduled_date]).to be_present
    end

    it '別ユーザーなら同じ日付でも登録できる' do
      user_a = create(:user)
      user_b = create(:user)
      create(:outfit, user: user_a, scheduled_date: Date.new(2026, 10, 1))

      other = build(:outfit, user: user_b, scheduled_date: Date.new(2026, 10, 1))
      expect(other).to be_valid
    end

    it '同じユーザーでも別日付なら登録できる' do
      user = create(:user)
      create(:outfit, user: user, scheduled_date: Date.new(2026, 10, 1))

      other = build(:outfit, user: user, scheduled_date: Date.new(2026, 10, 2))
      expect(other).to be_valid
    end
  end

  describe '洋服との関連' do
    it 'clothing_item_ids で洋服を関連付けられる' do
      user = create(:user)
      items = create_list(:clothing_item, 2, user: user)

      outfit = create(:outfit, user: user, clothing_item_ids: items.map(&:id))

      expect(outfit.clothing_items).to match_array(items)
    end
  end
end
