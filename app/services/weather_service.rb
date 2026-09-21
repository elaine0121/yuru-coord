# OpenWeatherMap から現在の天気情報を取得するサービス
# 取得に失敗した場合は nil を返し、呼び出し側で代替表示する
class WeatherService
  BASE_URL = "https://api.openweathermap.org/data/2.5/weather"

  # 指定した都市の現在の天気を取得する
  # @param city [String] 都市名（デフォルト: 東京）
  # @return [Hash, nil] { temperature:, description:, city: } 取得失敗時は nil
  def self.current(city: "Tokyo")
    api_key = ENV["OPENWEATHER_API_KEY"]
    if api_key.blank?
      Rails.logger.error("WeatherService: OPENWEATHER_API_KEY is blank")
      return nil
    end

    uri = build_uri(city, api_key)
    response = Net::HTTP.get_response(uri)
    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.error("WeatherService: bad status #{response.code}")
      return nil
    end

    parse(response.body)
  rescue StandardError => e
    Rails.logger.error("WeatherService error: #{e.class}: #{e.message}")
    nil
  end

  private_class_method def self.build_uri(city, api_key)
    params = {
      q: city,
      appid: api_key,
      units: "metric",
      lang: "ja"
    }
    URI.parse("#{BASE_URL}?#{URI.encode_www_form(params)}")
  end

  private_class_method def self.parse(body)
    data = JSON.parse(body)
    weather = data.dig("weather", 0)

    {
      temperature: data.dig("main", "temp"),
      description: weather&.dig("description"),
      city: data["name"]
    }
  end
end
