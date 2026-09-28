require 'rails_helper'

RSpec.describe '洋服・コーデ表示のシステムテスト', type: :system do
  include Warden::Test::Helpers

  before { Warden.test_mode! }
  after { Warden.test_reset! }

  describe 'マイ洋服一覧・詳細' do
    let(:user) { create(:user) }
    let(:category) { create(:category, name: 'トップス', sort_order: 1) }
    let!(:item) do
      create(:clothing_item, user: user, category: category, kind: 'Tシャツ', color: 'ホワイト',
                             memo: '定番の一枚', suitable_season: :summer)
    end

    it '登録済みの洋服が一覧に表示され、詳細ページで確認できる' do
      login_as user
      visit clothing_items_path

      expect(page).to have_content 'マイ洋服一覧'
      expect(page).to have_content 'トップス'
      expect(page).to have_content 'Tシャツ'
      expect(page).to have_content 'ホワイト'
      expect(page).to have_content '定番の一枚'

      click_link '詳細'

      expect(page).to have_current_path(clothing_item_path(item))
      expect(page).to have_content '洋服詳細'
      expect(page).to have_content '種類：Tシャツ'
      expect(page).to have_content '色：ホワイト'
      expect(page).to have_content 'メモ：定番の一枚'
    end
  end

  describe 'コーデの一覧・表示' do
    let(:user) { create(:user) }
    let(:category) { create(:category, name: 'トップス', sort_order: 1) }
    let!(:outfit) do
      outfit = create(:outfit, user: user, name: '通勤コーデ', scheduled_date: Date.today, situation: :commuter)
      create(:outfit_clothing_item, outfit: outfit,
                                    clothing_item: create(:clothing_item, user: user, category: category,
                                                                           kind: 'Yシャツ', color: 'ネイビー'))
      outfit
    end

    before { allow(WeatherService).to receive(:current).and_return(temperature: 25, description: '晴れ', city: 'Tokyo') }

    it '保存したコーデが一覧に表示される' do
      login_as user
      visit outfits_path

      expect(page).to have_content 'コーデ一覧'
      expect(page).to have_content '通勤コーデ'
      expect(page).to have_content '通勤'
      expect(page).to have_content 'トップス / Yシャツ（ネイビー）'
    end

    it 'トップページに今日のコーデが表示される' do
      login_as user
      visit root_path

      expect(page).to have_content '今日のコーデ'
      expect(page).to have_content '通勤コーデ'
      expect(page).to have_content 'トップス / Yシャツ（ネイビー）'
    end
  end
end
