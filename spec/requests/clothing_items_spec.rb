require 'rails_helper'

RSpec.describe "ClothingItems", type: :request do
  include Warden::Test::Helpers

  before { Warden.test_mode! }
  after { Warden.test_reset! }

  let(:user) { create(:user) }

  describe "未ログイン" do
    it "newへアクセスするとログイン画面へリダイレクトされる" do
      get new_clothing_item_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "ログイン中" do
    before { login_as(user) }

    it "newページが表示できる" do
      get new_clothing_item_path
      expect(response).to have_http_status(:ok)
    end

    it "洋服を登録できる" do
      category = create(:category)
      post clothing_items_path, params: { clothing_item: { category_id: category.id, kind: "Tシャツ", color: "ホワイト", memo: "定番の一枚" } }
      expect(response).to redirect_to(new_clothing_item_path)
      item = ClothingItem.last
      expect(item.user).to eq user
      expect(item.kind).to eq "Tシャツ"
    end
  end
end
