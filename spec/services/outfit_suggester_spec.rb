require 'rails_helper'

RSpec.describe OutfitSuggester, type: :service do
  let(:user) { create(:user) }
  let(:tops)    { create(:category, name: "トップス") }
  let(:bottoms) { create(:category, name: "ボトムス") }
  let(:outers)  { create(:category, name: "アウター") }
  let(:dresses) { create(:category, name: "ワンピース") }

  def item(category: tops, kind: "Tシャツ", season: "all_season")
    create(:clothing_item, user: user, category: category, kind: kind, suitable_season: season)
  end

  describe ".suggest" do
    context "夏（25℃）" do
      it "夏のトップスとボトムスを1つずつ提案する" do
        summer_top = item(category: tops, kind: "半袖", season: "summer")
        item(category: bottoms, kind: "パンツ", season: "summer")

        result = OutfitSuggester.suggest(user: user, temperature: 25)

        expect(result[:season]).to eq :summer
        expect(result[:season_label]).to eq "夏"
        expect(result[:items]).to match_array([summer_top, result[:items].last])
        expect(result[:items].map(&:category).map(&:name)).to eq ["トップス", "ボトムス"]
      end

      it "冬の服は含まれない" do
        item(category: tops, kind: "ニット", season: "winter")
        item(category: bottoms, kind: "パンツ", season: "winter")

        result = OutfitSuggester.suggest(user: user, temperature: 25)

        expect(result).to be_nil
      end
    end

    context "春・秋（15℃）" do
      it "春と秋の服が提案対象になる" do
        spring = item(category: tops, kind: "シャツ", season: "spring")
        item(category: bottoms, kind: "パンツ", season: "autumn")

        result = OutfitSuggester.suggest(user: user, temperature: 15)

        expect(result[:season]).to eq :spring_autumn
        expect(result[:season_label]).to eq "春・秋"
        expect(result[:items]).to include spring
      end

      it "15℃未満でもなければアウターは追加されない" do
        item(category: tops, kind: "シャツ", season: "autumn")
        item(category: bottoms, kind: "パンツ", season: "autumn")
        item(category: outers, kind: "パーカー", season: "autumn")

        result = OutfitSuggester.suggest(user: user, temperature: 15)

        expect(result[:items].map(&:category).map(&:name)).to eq ["トップス", "ボトムス"]
      end
    end

    context "冬（8℃）" do
      it "冬の服にアウターも追加される" do
        item(category: tops, kind: "ニット", season: "winter")
        item(category: bottoms, kind: "パンツ", season: "winter")
        item(category: outers, kind: "コート", season: "winter")

        result = OutfitSuggester.suggest(user: user, temperature: 8)

        expect(result[:season]).to eq :winter
        expect(result[:season_label]).to eq "冬"
        expect(result[:items].map(&:category).map(&:name)).to eq ["トップス", "ボトムス", "アウター"]
      end
    end

    context "ワンピース" do
      it "ワンピースがあればそれを1着として提案する" do
        dress = item(category: dresses, kind: "ワンピース", season: "summer")
        item(category: tops, kind: "半袖", season: "summer")
        item(category: bottoms, kind: "パンツ", season: "summer")

        result = OutfitSuggester.suggest(user: user, temperature: 25)

        expect(result[:items]).to contain_exactly dress
      end
    end

    context "通年の洋服" do
      it "どの季節でも提案対象になる" do
        all = item(category: tops, kind: "Tシャツ", season: "all_season")
        item(category: bottoms, kind: "パンツ", season: "all_season")

        result = OutfitSuggester.suggest(user: user, temperature: 25)

        expect(result[:items]).to include all
      end
    end

    context "気温が取得できないとき" do
      it "nil を返す" do
        expect(OutfitSuggester.suggest(user: user, temperature: nil)).to be_nil
      end
    end

    context "季節設定がない洋服だけのとき" do
      it "おすすめを提案できない（nil）" do
        item(category: tops, kind: "Tシャツ", season: nil)
        item(category: bottoms, kind: "パンツ", season: nil)

        expect(OutfitSuggester.suggest(user: user, temperature: 25)).to be_nil
      end
    end
  end
end
