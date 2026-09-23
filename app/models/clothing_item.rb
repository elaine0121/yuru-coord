class ClothingItem < ApplicationRecord
  belongs_to :user
  belongs_to :category
  has_many :outfit_clothing_items, dependent: :destroy
  has_many :outfits, through: :outfit_clothing_items

  enum :suitable_season, { spring: 0, summer: 1, autumn: 2, winter: 3, all_season: 4 }

  SUITABLE_SEASON_LABELS = {
    spring: "春", summer: "夏", autumn: "秋", winter: "冬", all_season: "通年"
  }.freeze

  # 種類の網羅的な選択肢（README「種類網羅＋人気順」で定義）。
  # キーは Category#sort_order（トップス1 / ボトムス2 / アウター3 / ワンピース4）。
  # 並びは人気・使用頻度の高い順、男女問わず一般的な種類を幅広くカバー。
  KINDS_BY_CATEGORY_SORT_ORDER = {
    1 => %w[Tシャツ Yシャツ ブラウス セーター パーカー ポロシャツ カーディガン タンクトップ トレーナー ニット シャツ ベスト ワイシャツ].freeze,
    2 => %w[デニム スラックス チノパン スカート ショートパンツ タイトスカート カーゴパンツ レギンス キュロット ロングスカート].freeze,
    3 => %w[コート ジャケット パーカー ブルゾン ダウンジャケット トレンチコート チェスターコート ドカジャン].freeze,
    4 => %w[ワンピース ロングワンピース シャツワンピース ニットワンピース ジャンパースカート サロペット].freeze
  }.freeze

  validates :kind, presence: true

  def in_use?
    outfit_clothing_items.exists?
  end
end
