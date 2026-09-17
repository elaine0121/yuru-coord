class OutfitsController < ApplicationController
  before_action :authenticate_user!

  def new
    @outfit = current_user.outfits.build
    @outfit.scheduled_date = Date.tomorrow
    @clothing_items = current_user.clothing_items.order(:id)
  end

  def create
    @outfit = current_user.outfits.build(outfit_params)
    @clothing_items = current_user.clothing_items.order(:id)

    if @outfit.save
      redirect_to root_path, notice: "コーデを保存しました！"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  # 選んだ洋服は現在のユーザーが所有するものだけに絞って保存する
  def outfit_params
    selected_ids = Array(params.dig(:outfit, :clothing_item_ids)).map(&:to_i)
    own_ids = current_user.clothing_items.pluck(:id)

    params.require(:outfit)
          .permit(:scheduled_date)
          .merge(clothing_item_ids: selected_ids & own_ids)
  end
end
