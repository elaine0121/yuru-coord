require 'rails_helper'

RSpec.describe "ClothingItems", type: :request do
  include Warden::Test::Helpers

  before { Warden.test_mode! }
  after { Warden.test_reset! }

  let(:user) { create(:user) }

  describe "未ログイン" do
    it "indexへアクセスするとログイン画面へリダイレクトされる" do
      get clothing_items_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "showへアクセスするとログイン画面へリダイレクトされる" do
      item = create(:clothing_item)
      get clothing_item_path(item)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "newへアクセスするとログイン画面へリダイレクトされる" do
      get new_clothing_item_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "ログイン中" do
    before { login_as(user) }

    it "indexで登録した洋服の一覧が表示できる" do
      item = create(:clothing_item, user: user)
      get clothing_items_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(item.kind)
      expect(response.body).to include(item.category.name)
    end

    it "ヘッダーに洋服一覧・登録・ログアウトのリンクが表示される" do
      get clothing_items_path
      expect(response.body).to include("マイ洋服一覧")
      expect(response.body).to include("洋服を登録する")
      expect(response.body).to include("ログアウト")
    end

    it "詳細ページが表示できる" do
      item = create(:clothing_item, user: user)
      get clothing_item_path(item)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(item.kind)
      expect(response.body).to include(item.memo)
    end

    it "他人の洋服の詳細にはアクセスできない" do
      other_item = create(:clothing_item)
      get clothing_item_path(other_item)
      expect(response).to have_http_status(:not_found)
    end

    it "newページが表示できる" do
      get new_clothing_item_path
      expect(response).to have_http_status(:ok)
    end

    it "洋服を登録すると一覧へリダイレクトされる" do
      category = create(:category)
      post clothing_items_path, params: { clothing_item: { category_id: category.id, kind: "Tシャツ", color: "ホワイト", memo: "定番の一枚" } }
      expect(response).to redirect_to(clothing_items_path)
      item = ClothingItem.last
      expect(item.user).to eq user
      expect(item.kind).to eq "Tシャツ"
    end
  end
end
