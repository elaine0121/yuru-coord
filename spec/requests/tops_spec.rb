require 'rails_helper'

RSpec.describe "Tops", type: :request do
  include Warden::Test::Helpers

  before { Warden.test_mode! }
  after { Warden.test_reset! }

  let(:user) { create(:user) }

  describe "未ログイン" do
    it "今日のコーデは表示されない（ログイン画面の導線が表示される）" do
      get root_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("ログイン")
      expect(response.body).not_to include("今日のコーデ")
    end
  end

  describe "ログイン中" do
    before { login_as(user) }

    it "今日のコーデが未設定のときは案内が表示される" do
      get root_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("今日のコーデはまだ設定されていません")
      expect(response.body).to include("明日のコーデを登録する")
    end

    it "当日のコーデが保存されているときは洋服が表示される" do
      outfit = create(:outfit, user: user, scheduled_date: Date.today)
      category = create(:category)
      item1 = create(:clothing_item, user: user, category: category, kind: "Tシャツ", color: "ホワイト")
      item2 = create(:clothing_item, user: user, category: category, kind: "パンツ", color: "ネイビー")
      create(:outfit_clothing_item, outfit: outfit, clothing_item: item1)
      create(:outfit_clothing_item, outfit: outfit, clothing_item: item2)

      get root_path
      expect(response.body).to include("今日のコーデ")
      expect(response.body).to include(item1.kind)
      expect(response.body).to include(item2.kind)
    end

    it "明日のコーデは今日のコーデとして表示されない" do
      create(:outfit, user: user, scheduled_date: Date.tomorrow)

      get root_path
      expect(response.body).to include("今日のコーデはまだ設定されていません")
    end
  end
end
