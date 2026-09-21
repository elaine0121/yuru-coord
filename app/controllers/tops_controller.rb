class TopsController < ApplicationController
  WEATHER_CITY = "Tokyo"

  def index
    return unless user_signed_in?

    @today_outfit = current_user.outfits
                               .includes(clothing_items: :category)
                               .find_by(scheduled_date: Date.today)
    @weather = WeatherService.current(city: WEATHER_CITY)

    # 今日のコーデが未設定でも、気温・季節に合わせたおすすめを常に用意しておく
    @suggestion = OutfitSuggester.suggest(
      user: current_user,
      temperature: @weather&.dig(:temperature)
    )
  end
end
