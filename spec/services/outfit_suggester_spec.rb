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

    context "シチュエーション絞り込み" do
      it "通勤時はワンピースがあってもトップス+ボトムスを優先する" do
        item(category: dresses, kind: "ワンピース", season: "summer")
        top = item(category: tops, kind: "半袖", season: "summer")
        bottom = item(category: bottoms, kind: "パンツ", season: "summer")

        result = OutfitSuggester.suggest(user: user, temperature: 25, situation: :commuter)

        expect(result[:items]).to match_array([top, bottom])
      end

      it "フォーマル時はワンピースを優先する" do
        dress = item(category: dresses, kind: "ワンピース", season: "summer")
        item(category: tops, kind: "半袖", season: "summer")
        item(category: bottoms, kind: "パンツ", season: "summer")

        result = OutfitSuggester.suggest(user: user, temperature: 25, situation: :formal)

        expect(result[:items]).to contain_exactly dress
      end

      it "デート時はワンピースを優先する" do
        dress = item(category: dresses, kind: "ワンピース", season: "summer")
        item(category: tops, kind: "半袖", season: "summer")
        item(category: bottoms, kind: "パンツ", season: "summer")

        result = OutfitSuggester.suggest(user: user, temperature: 25, situation: :date)

        expect(result[:items]).to contain_exactly dress
      end
    end

    context "再抽選（offset）" do
      it "オフセットを変えると別のトップスが選ばれる" do
        top1 = item(category: tops, kind: "半袖A", season: "summer")
        top2 = item(category: tops, kind: "半袖B", season: "summer")
        bottom = item(category: bottoms, kind: "パンツ", season: "summer")

        first = OutfitSuggester.suggest(user: user, temperature: 25, situation: :commuter, offset: 0)
        second = OutfitSuggester.suggest(user: user, temperature: 25, situation: :commuter, offset: 1)

        expect(first[:items]).to include top1, bottom
        expect(second[:items]).not_to include top1
        expect(second[:items]).to include top2
      end
    end

    context "直近3日に着た洋服の除外" do
      it "直近3日に着た洋服を候補から除外する" do
        recent_top = item(category: tops, kind: "昨日のTシャツ", season: "summer")
        fresh_top  = item(category: tops, kind: "新しい半袖", season: "summer")
        bottom     = item(category: bottoms, kind: "パンツ", season: "summer")

        # 昨日に recent_top を使ったコーデを保存（直近3日に該当）
        outfit = create(:outfit, user: user, scheduled_date: Date.yesterday)
        create(:outfit_clothing_item, outfit: outfit, clothing_item: recent_top)

        result = OutfitSuggester.suggest(user: user, temperature: 25, situation: :commuter)

        expect(result[:items].map(&:id)).not_to include recent_top.id
        expect(result[:items]).to include fresh_top
      end

      it "4日以上前に着た洋服は除外されない" do
        old_top = item(category: tops, kind: "古いTシャツ", season: "summer")
        bottom  = item(category: bottoms, kind: "パンツ", season: "summer")

        outfit = create(:outfit, user: user, scheduled_date: Date.today - 4)
        create(:outfit_clothing_item, outfit: outfit, clothing_item: old_top)

        result = OutfitSuggester.suggest(user: user, temperature: 25, situation: :commuter)

        expect(result[:items]).to include old_top
      end

      it "除外すると候補が足りない場合は全候補にフォールバックして提案する" do
        worn_top    = item(category: tops, kind: "昨日の半袖", season: "summer")
        worn_bottom = item(category: bottoms, kind: "昨日のパンツ", season: "summer")

        outfit = create(:outfit, user: user, scheduled_date: Date.yesterday)
        create(:outfit_clothing_item, outfit: outfit, clothing_item: worn_top)
        create(:outfit_clothing_item, outfit: outfit, clothing_item: worn_bottom)

        result = OutfitSuggester.suggest(user: user, temperature: 25, situation: :commuter)

        expect(result[:items].map(&:id)).to include worn_top.id, worn_bottom.id
      end
    end
  end
end
