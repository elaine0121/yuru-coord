class Outfit < ApplicationRecord
  belongs_to :user
  has_many :outfit_clothing_items, dependent: :destroy
  has_many :clothing_items, through: :outfit_clothing_items

  validates :scheduled_date, presence: true
  validate :one_outfit_per_day

  enum :situation, { commuter: 0, date: 1, casual: 2, formal: 3 }
  SITUATION_LABELS = { commuter: "通勤", date: "デート", casual: "カジュアル", formal: "フォーマル" }.freeze

  def situation_text
    self.class::SITUATION_LABELS[situation.to_sym]
  end

  private

  def one_outfit_per_day
    return if scheduled_date.blank?

    existed = self.class.where(user_id: user_id, scheduled_date: scheduled_date).where.not(id: id).exists?
    errors.add(:base, "着用予定日は1日1件までです") if existed
  end
end
