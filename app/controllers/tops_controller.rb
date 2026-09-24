class TopsController < ApplicationController
  DEFAULT_CITY = "Tokyo"
  WEATHER_CITIES = %w[Tokyo Osaka Sapporo Fukuoka Sendai Nagoya Kobe Kyoto Hiroshima].freeze

  def index
    return unless user_signed_in?

    @today_outfit = current_user.outfits
                               .includes(clothing_items: :category)
                               .find_by(scheduled_date: Date.today)
    @selected_city = WEATHER_CITIES.include?(params[:city]) ? params[:city] : DEFAULT_CITY
    @weather = WeatherService.current(city: @selected_city)

    # シチュエーションと再抽選(attempt)をクエリから受け取って、おすすめを算出する
    @selected_situation = params[:situation].presence&.to_sym
    attempt = params[:attempt].to_i
    @suggestion = OutfitSuggester.suggest(
      user: current_user,
      temperature: @weather&.dig(:temperature),
      situation: @selected_situation,
      offset: attempt
    )
  end
end
