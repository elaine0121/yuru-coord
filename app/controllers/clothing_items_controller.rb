class ClothingItemsController < ApplicationController
  before_action :authenticate_user!

  def index
    @clothing_items = current_user.clothing_items.includes(:category).order(:id)
  end

  def show
    @clothing_item = current_user.clothing_items.find(params[:id])
  end

  def new
    @clothing_item = ClothingItem.new
    @categories = Category.order(:sort_order)
  end

  def create
    @clothing_item = current_user.clothing_items.build(clothing_item_params)
    @categories = Category.order(:sort_order)

    if @clothing_item.save
      redirect_to clothing_items_path, notice: "洋服を登録しました！"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @clothing_item = current_user.clothing_items.find(params[:id])
    @categories = Category.order(:sort_order)
  end

  def update
    @clothing_item = current_user.clothing_items.find(params[:id])
    @categories = Category.order(:sort_order)

    if @clothing_item.update(clothing_item_params)
      redirect_to clothing_item_path(@clothing_item), notice: "洋服を更新しました！"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def clothing_item_params
    params.require(:clothing_item).permit(:category_id, :kind, :color, :memo)
  end
end
