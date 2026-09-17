require 'rails_helper'

RSpec.describe "Outfits", type: :request do
  include Warden::Test::Helpers

  before { Warden.test_mode! }
  after { Warden.test_reset! }

  let(:user) { create(:user) }

  describe "未ログイン" do
    it "newへアクセスするとログイン画面へリダイレクトされる" do
      get new_outfit_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "createするとログイン画面へリダイレクトされる" do
      post outfits_path, params: { outfit: { scheduled_date: Date.tomorrow } }
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "ログイン中" do
    before { login_as(user) }

    it "newページが表示され、着る日が明日になっている" do
      get new_outfit_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(Date.tomorrow.to_s)
    end

    it "自分の洋服がチェックボックスで表示される" do
      item = create(:clothing_item, user: user, kind: "Tシャツ", color: "ホワイト")
      get new_outfit_path
      expect(response.body).to include(item.kind)
    end

    it "明日の日付でコーデを保存できる" do
      items = create_list(:clothing_item, 3, user: user)
      post outfits_path, params: { outfit: { scheduled_date: Date.tomorrow, clothing_item_ids: items.map(&:id) } }

      expect(response).to redirect_to(root_path)
      outfit = Outfit.last
      expect(outfit.user).to eq user
      expect(outfit.scheduled_date).to eq Date.tomorrow
      expect(outfit.clothing_items).to match_array(items)
    end

    it "他人の洋服を組み込もうとしても無視される" do
      my_item = create(:clothing_item, user: user)
      other_item = create(:clothing_item)

      post outfits_path, params: { outfit: { scheduled_date: Date.tomorrow, clothing_item_ids: [my_item.id, other_item.id] } }

      outfit = Outfit.last
      expect(outfit.clothing_items).to eq [my_item]
    end

    it "同じ日付で2回保存するとエラーになる" do
      create(:outfit, user: user, scheduled_date: Date.tomorrow)

      post outfits_path, params: { outfit: { scheduled_date: Date.tomorrow, clothing_item_ids: [] } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("は1日1件までです")
    end
  end
end
