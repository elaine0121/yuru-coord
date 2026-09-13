require 'rails_helper'

RSpec.describe ClothingItem, type: :model do
  describe 'バリデーション' do
    it '有効な属性なら登録できる' do
      item = build(:clothing_item)
      expect(item).to be_valid
    end

    it 'userが無ければ無効' do
      item = build(:clothing_item, user: nil)
      expect(item).to be_invalid
    end

    it 'categoryが無ければ無効' do
      item = build(:clothing_item, category: nil)
      expect(item).to be_invalid
    end

    it 'kindが空なら無効' do
      item = build(:clothing_item, kind: nil)
      expect(item).to be_invalid
    end
  end
end
