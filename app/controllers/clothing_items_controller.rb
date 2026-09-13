class ClothingItemsController < ApplicationController
  before_action :authenticate_user!

  def new
    @clothing_item = ClothingItem.new
    @categories = Category.order(:sort_order)
  end

  def create
    @clothing_item = current_user.clothing_items.build(clothing_item_params)
    @categories = Category.order(:sort_order)

    if @clothing_item.save
      redirect_to new_clothing_item_path, notice: "洋服を登録しました！"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def clothing_item_params
    params.require(:clothing_item).permit(:category_id, :kind, :color, :memo)
  end
end
