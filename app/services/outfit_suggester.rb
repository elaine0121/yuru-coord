# 気温・季節に合わせたコーデ1着分を提案する
# season 判定は日本基準の気温から推測する
class OutfitSuggester
  TOP_NAME       = "トップス"
  BOTTOM_NAME    = "ボトムス"
  OUTER_NAME     = "アウター"
  DRESS_NAME     = "ワンピース"
  WINTER_TEMP    = 12.0
  MID_TEMP       = 20.0
  OUTER_ADD_TEMP = 15.0

  # season ごとに適合する suitable_season の enum 値（通年=4 は常に含む）
  SEASON_CODES = {
    winter: [3, 4],
    spring_autumn: [0, 2, 4],
    summer: [1, 4]
  }.freeze

  SEASON_LABELS = {
    spring_autumn: "春・秋",
    summer: "夏",
    winter: "冬"
  }.freeze

  def self.suggest(user:, temperature:)
    new(user: user, temperature: temperature).suggest
  end

  def initialize(user:, temperature:)
    @user = user
    @temperature = temperature&.to_f
  end

  # 戻り値: { season:, season_label:, temperature:, items: [ClothingItem, ...] } または nil
  def suggest
    return nil if @temperature.nil?

    season = infer_season(@temperature)
    pool = matching_items(season)
    outfit = build_outfit(pool, @temperature)

    return nil if outfit.empty?

    {
      season: season,
      season_label: SEASON_LABELS[season],
      temperature: @temperature,
      items: outfit
    }
  end

  private

  # 気温から季節を推定（日本基準）
  def infer_season(temp)
    return :winter if temp < WINTER_TEMP
    return :spring_autumn if temp < MID_TEMP

    :summer
  end

  # 判定した季節に合う（通年を含む）洋服を DB 層で絞り込む
  def matching_items(season)
    @user.clothing_items
         .joins(:category)
         .where(suitable_season: SEASON_CODES.fetch(season))
         .where(categories: { name: [TOP_NAME, BOTTOM_NAME, OUTER_NAME, DRESS_NAME] })
         .includes(:category)
  end

  # ワンピース優先、なければトップス+ボトムス、寒いときはアウター追加
  def build_outfit(pool, temp)
    tops    = pool.select { |i| i.category&.name == TOP_NAME }
    bottoms = pool.select { |i| i.category&.name == BOTTOM_NAME }
    outers  = pool.select { |i| i.category&.name == OUTER_NAME }
    dresses = pool.select { |i| i.category&.name == DRESS_NAME }

    result = []
    if dresses.any?
      result << dresses.first
    else
      result << tops.first if tops.any?
      result << bottoms.first if bottoms.any?
    end
    result << outers.first if outers.any? && temp < OUTER_ADD_TEMP

    result.compact
  end
end
