class OutfitsController < ApplicationController
  before_action :authenticate_user!

  def index
    @outfits = current_user.outfits
                           .includes(clothing_items: :category)
                           .order(scheduled_date: :desc)
  end

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

  # 過去コーデの構成をコピーして新しい日付に再利用する
  def reuse
    @source = current_user.outfits.find(params[:id])
    @copy = current_user.outfits.build
    @copy.clothing_item_ids = @source.clothing_item_ids

    if request.post?
      @copy.situation = @source.situation
      @copy.assign_attributes(reuse_params)
      if @copy.save
        redirect_to outfits_path, notice: "コーデを再利用しました！"
        return
      end
      render :reuse, status: :unprocessable_entity
    else
      @copy.scheduled_date = Date.tomorrow
      @copy.name = @source.name
      @copy.situation = @source.situation
      render :reuse
    end
  end

  private

  # 選んだ洋服は現在のユーザーが所有するものだけに絞って保存する
  def outfit_params
    selected_ids = Array(params.dig(:outfit, :clothing_item_ids)).map(&:to_i)
    own_ids = current_user.clothing_items.pluck(:id)

    params.require(:outfit)
          .permit(:scheduled_date, :name, :situation)
          .merge(clothing_item_ids: selected_ids & own_ids)
  end

  # 再利用時は日付と名前だけ受け取り、洋服は元コーデの構成を引き継ぐ
  def reuse_params
    params.require(:outfit).permit(:scheduled_date, :name)
  end
end
