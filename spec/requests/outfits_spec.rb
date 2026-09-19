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

    it "明日の日付でコーデを保存でき、一覧画面へ遷移して成功メッセージが表示される" do
      items = create_list(:clothing_item, 3, user: user)
      post outfits_path, params: { outfit: { scheduled_date: Date.tomorrow, clothing_item_ids: items.map(&:id) } }

      expect(response).to redirect_to(outfits_path)
      expect(flash[:notice]).to eq "コーデを保存しました！"
      get outfits_path
      expect(response.body).to include("コーデを保存しました！")
      outfit = Outfit.last
      expect(outfit.user).to eq user
      expect(outfit.scheduled_date).to eq Date.tomorrow
      expect(outfit.clothing_items).to match_array(items)
    end

    it "コーデ名を指定して保存できる" do
      post outfits_path, params: { outfit: { scheduled_date: Date.tomorrow, name: "通勤コーデ", clothing_item_ids: [] } }

      expect(Outfit.last.name).to eq "通勤コーデ"
    end

    it "シチュエーションを指定して保存できる" do
      post outfits_path, params: { outfit: { scheduled_date: Date.tomorrow, situation: "date", clothing_item_ids: [] } }

      expect(Outfit.last.situation).to eq "date"
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

    it "一覧が表示され、コーデ名と洋服が見える" do
      outfit = create(:outfit, user: user, scheduled_date: Date.yesterday, name: "週末コーデ", situation: "casual")
      category = create(:category)
      item = create(:clothing_item, user: user, category: category, kind: "Tシャツ", color: "ホワイト")
      create(:outfit_clothing_item, outfit: outfit, clothing_item: item)

      get outfits_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("週末コーデ")
      expect(response.body).to include(item.kind)
      expect(response.body).to include("カジュアル")
    end

    it "規約のないときは空の案内が表示される" do
      get outfits_path
      expect(response.body).to include("まだコーデが登録されていません")
    end

    describe "再利用" do
      it "元コーデの構成が再利用画面に表示される" do
        source = create(:outfit, user: user, scheduled_date: Date.yesterday, name: "通勤コーデ")
        category = create(:category)
        item = create(:clothing_item, user: user, category: category, kind: "Tシャツ", color: "ホワイト")
        create(:outfit_clothing_item, outfit: source, clothing_item: item)

        get reuse_outfit_path(source)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("通勤コーデ")
        expect(response.body).to include(item.kind)
      end

      it "過去コーデの構成をコピーして新しい日付に保存できる" do
        source = create(:outfit, user: user, scheduled_date: Date.yesterday, situation: "date")
        items = create_list(:clothing_item, 2, user: user)
        items.each { |item| create(:outfit_clothing_item, outfit: source, clothing_item: item) }
        new_date = Date.new(2026, 10, 5)

        post reuse_outfit_path(source, outfit: { scheduled_date: new_date })

        expect(response).to redirect_to(outfits_path)
        copy = Outfit.find_by(scheduled_date: new_date)
        expect(copy).not_to be_nil
        expect(copy.user).to eq user
        expect(copy.clothing_items).to match_array(items)
        expect(copy.situation).to eq "date"
      end

      it "既に使われている日付への再利用はエラーになる" do
        source = create(:outfit, user: user, scheduled_date: Date.yesterday)
        create(:outfit, user: user, scheduled_date: Date.tomorrow)

        post reuse_outfit_path(source, outfit: { scheduled_date: Date.tomorrow })

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("1日1件までです")
      end
    end
  end
end
