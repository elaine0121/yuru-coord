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
    before do
      login_as(user)
      # テストでは外部API（OpenWeatherMap）を呼ばず、天気取得をモックする
      allow(WeatherService).to receive(:current).and_return(nil)
    end

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

    it "天気が取得できるときは都市・天気・気温が表示される" do
      allow(WeatherService).to receive(:current).and_return(
        { temperature: 22.5, description: "晴れ", city: "Tokyo" }
      )

      get root_path
      expect(response.body).to include("今日のお天気")
      expect(response.body).to include("Tokyo")
      expect(response.body).to include("晴れ")
      expect(response.body).to include("23℃")
    end

    it "天気が取得できないときは代替表示がされる" do
      get root_path
      expect(response.body).to include("天気情報を取得できませんでした")
    end

    it "今日のコーデが未設定のとき、気温に合わせたおすすめコーデが表示される" do
      allow(WeatherService).to receive(:current).and_return(
        { temperature: 25.0, description: "晴れ", city: "Tokyo" }
      )
      tops = create(:category, name: "トップス")
      bottoms = create(:category, name: "ボトムス")
      create(:clothing_item, user: user, category: tops, kind: "半袖", color: "ホワイト", suitable_season: :summer)
      create(:clothing_item, user: user, category: bottoms, kind: "パンツ", color: "ネイビー", suitable_season: :summer)

      get root_path

      expect(response.body).to include("今日のおすすめコーデ")
      expect(response.body).to include("夏向け")
      expect(response.body).to include("半袖")
      expect(response.body).to include("パンツ")
    end

    it "季節に合う洋服がないときはおすすめを提案できない旨が表示される" do
      allow(WeatherService).to receive(:current).and_return(
        { temperature: 25.0, description: "晴れ", city: "Tokyo" }
      )
      tops = create(:category, name: "トップス")
      create(:clothing_item, user: user, category: tops, kind: "ニット", color: "グレー", suitable_season: :winter)

      get root_path

      expect(response.body).to include("おすすめを提案できません")
    end

    it "シチュエーションを指定すると絞り込んだ提案が表示される" do
      allow(WeatherService).to receive(:current).and_return(
        { temperature: 25.0, description: "晴れ", city: "Tokyo" }
      )
      tops_c = create(:category, name: "トップス")
      bottoms_c = create(:category, name: "ボトムス")
      dress_c = create(:category, name: "ワンピース")
      top = create(:clothing_item, user: user, category: tops_c, kind: "半袖", color: "ホワイト", suitable_season: :summer)
      create(:clothing_item, user: user, category: bottoms_c, kind: "パンツ", color: "グレー", suitable_season: :summer)
      dress = create(:clothing_item, user: user, category: dress_c, kind: "ワンピース", color: "ネイビー", suitable_season: :summer)

      get root_path, params: { situation: "commuter" }

      expect(response.body).to include("今日のおすすめコーデ")
      expect(response.body).to include(top.kind)
      expect(response.body).to include("パンツ")
      expect(response.body).not_to include(dress.kind)
      expect(response.body).to include("別のコーデを見る")
    end

    it "city を指定するとその都市で天気を取得して表示する" do
      allow(WeatherService).to receive(:current).and_return(
        { temperature: 18.0, description: "曇り", city: "Osaka" }
      )

      get root_path, params: { city: "Osaka" }

      expect(WeatherService).to have_received(:current).with(city: "Osaka")
      expect(response.body).to include("今日のお天気")
      expect(response.body).to include("Osaka")
    end

    it "未対応の city を指定した場合はデフォルトの東京で取得する" do
      allow(WeatherService).to receive(:current).and_return(
        { temperature: 22.0, description: "晴れ", city: "Tokyo" }
      )

      get root_path, params: { city: "Narnia" }

      expect(WeatherService).to have_received(:current).with(city: "Tokyo")
    end
  end
end
