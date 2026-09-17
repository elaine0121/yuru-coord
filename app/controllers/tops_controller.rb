class TopsController < ApplicationController
  def index
    return unless user_signed_in?

    @today_outfit = current_user.outfits
                               .includes(clothing_items: :category)
                               .find_by(scheduled_date: Date.today)
  end
end
