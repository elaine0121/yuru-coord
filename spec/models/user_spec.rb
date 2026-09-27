require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーション' do
    it '有効な属性なら登録できる' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'emailが空なら無効' do
      user = build(:user, email: '')
      expect(user).to be_invalid
    end

    it 'emailの形式が不正なら無効' do
      user = build(:user, email: 'not-an-email')
      expect(user).to be_invalid
    end

    it 'パスワードが6文字未満なら無効' do
      user = build(:user, password: '12345', password_confirmation: '12345')
      expect(user).to be_invalid
    end

    it 'パスワード確認が一致しなければ無効' do
      user = build(:user, password: 'password123', password_confirmation: 'different123')
      expect(user).to be_invalid
    end
  end

  describe '関連' do
    it '複数の洋服を持つことができる' do
      user = create(:user)
      create_list(:clothing_item, 2, user: user)

      expect(user.clothing_items.size).to eq 2
    end

    it '複数のコーデを持つことができる（異なる日付）' do
      user = create(:user)
      create(:outfit, user: user, scheduled_date: Date.tomorrow)
      create(:outfit, user: user, scheduled_date: Date.tomorrow + 1.day)

      expect(user.outfits.size).to eq 2
    end
  end
end
