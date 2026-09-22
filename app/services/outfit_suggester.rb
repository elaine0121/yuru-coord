# 気温・季節・シチュエーションに合わせたコーデ1着分を提案する
# season 判定は日本基準の気温から推測する
class OutfitSuggester
  TOP_NAME       = "トップス"
  BOTTOM_NAME    = "ボトムス"
  OUTER_NAME     = "アウター"
  DRESS_NAME     = "ワンピース"
  WINTER_TEMP    = 12.0
  MID_TEMP       = 20.0
  OUTER_ADD_TEMP = 15.0

  # ワンピースを優先するシチュエーション（フォーマル・デート）
  DRESS_FIRST_SITUATION = [:formal, :date].freeze

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

  def self.suggest(user:, temperature:, situation: nil, offset: 0)
    new(user: user, temperature: temperature, situation: situation, offset: offset).suggest
  end

  def initialize(user:, temperature:, situation: nil, offset: 0)
    @user = user
    @temperature = temperature&.to_f
    @situation = situation&.to_sym
    @offset = offset
  end

  # 戻り値: { season:, season_label:, temperature:, situation:, items: [ClothingItem, ...] } または nil
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
      situation: @situation,
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

  # 候補から offset 番目の洋服を取る（範囲外は先頭に循環）
  def pick(pool)
    return if pool.empty?

    pool[@offset % pool.size]
  end

  # 判定した季節に合う（通年を含む）洋服を DB 層で絞り込む
  def matching_items(season)
    @user.clothing_items
         .joins(:category)
         .where(suitable_season: SEASON_CODES.fetch(season))
         .where(categories: { name: [TOP_NAME, BOTTOM_NAME, OUTER_NAME, DRESS_NAME] })
         .includes(:category)
  end

  # 通勤・カジュアルはトップス+ボトムス、フォーマル・デート・未指定はワンピース優先
  # オフセット（再抽選）で候補の別の組み合わせを選ぶ
  def build_outfit(pool, temp)
    tops    = pool.select { |i| i.category&.name == TOP_NAME }.sort_by(&:id)
    bottoms = pool.select { |i| i.category&.name == BOTTOM_NAME }.sort_by(&:id)
    outers  = pool.select { |i| i.category&.name == OUTER_NAME }.sort_by(&:id)
    dresses = pool.select { |i| i.category&.name == DRESS_NAME }.sort_by(&:id)

    result = if dress_first? && dresses.any?
               [pick(dresses)]
    elsif tops.any? && bottoms.any?
               [pick(tops), pick(bottoms)]
    elsif dresses.any?
               [pick(dresses)]
    elsif tops.any?
               [pick(tops)]
    elsif bottoms.any?
               [pick(bottoms)]
    else
               []
    end

    result << pick(outers) if outers.any? && temp < OUTER_ADD_TEMP
    result.compact
  end

  def dress_first?
    @situation.nil? || DRESS_FIRST_SITUATION.include?(@situation)
  end
end
