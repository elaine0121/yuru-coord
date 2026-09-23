class ClothingItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_categories_and_kinds, only: [:new, :create, :edit, :update]

  def index
    @clothing_items = current_user.clothing_items.includes(:category).order(:id)
  end

  def show
    @clothing_item = current_user.clothing_items.find(params[:id])
  end

  def new
    @clothing_item = ClothingItem.new
  end

  def create
    @clothing_item = current_user.clothing_items.build(clothing_item_params)

    if @clothing_item.save
      redirect_to clothing_items_path, notice: "洋服を登録しました！"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @clothing_item = current_user.clothing_items.find(params[:id])
  end

  def update
    @clothing_item = current_user.clothing_items.find(params[:id])

    if @clothing_item.update(clothing_item_params)
      redirect_to clothing_item_path(@clothing_item), notice: "洋服を更新しました！"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @clothing_item = current_user.clothing_items.find(params[:id])

    if @clothing_item.in_use?
      redirect_to clothing_item_path(@clothing_item), alert: "この洋服はコーデで使用中のため削除できません。"
    else
      @clothing_item.destroy
      redirect_to clothing_items_path, notice: "洋服を削除しました。"
    end
  end

  private

  # カテゴリ別の種類選択肢を@kinds_by_categoryに詰める（種類はカテゴリで連動）
  def load_categories_and_kinds
    @categories = Category.order(:sort_order)
    @kinds_by_category = @categories.to_h do |c|
      [c.id, ClothingItem::KINDS_BY_CATEGORY_SORT_ORDER[c.sort_order] || []]
    end
  end

  def clothing_item_params
    params.require(:clothing_item).permit(:category_id, :kind, :color, :memo, :suitable_season)
  end
end
