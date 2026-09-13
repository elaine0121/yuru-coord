require "rails_helper"

RSpec.describe Category, type: :model do
  describe "バリデーション" do
    it "name と sort_order があれば有効" do
      expect(build(:category)).to be_valid
    end

    it "name が空なら無効" do
      expect(build(:category, name: nil)).to be_invalid
    end

    it "name が重複していれば無効" do
      create(:category, name: "トップス")
      expect(build(:category, name: "トップス")).to be_invalid
    end

    it "sort_order が空なら無効" do
      expect(build(:category, sort_order: nil)).to be_invalid
    end
  end
end
