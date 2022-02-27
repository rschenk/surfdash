require_relative './browser'
require 'nokogiri'

class SurflineCountyScraper
  Spot = Struct.new(:name, :wave_range, :conditions)

  attr_accessor :url

  def initialize(url = nil)
    @url = url || 'https://www.surfline.com/surf-reports-forecasts-cams/united-states/florida/brevard-county/4148826'
  end

  def spots
    @spots ||= scrape_spots
  end


  private

  def scrape_spots
    report_json
      .dig('props', 'pageProps', 'ssrReduxState', 'map', 'spots')
      .map { |spot| scrape_spot spot }
      .uniq { |spot| spot.name }
  end

  def scrape_spot(spot_json)
    name = spot_json['name']
    conditions = spot_json.dig('conditions', 'value').to_s.downcase
    wave_range = "#{spot_json.dig('waveHeight', 'min')}-#{spot_json.dig('waveHeight', 'max')} ft"

    Spot.new(name, wave_range, conditions)
  end

  def report_json
    return @report_json unless @report_json.nil?

    data_tag = doc.css("script#__NEXT_DATA__").first
    json_text = data_tag.text

    @report_json = JSON.parse(json_text)
  end

  def doc
    @doc ||= Nokogiri::HTML( Browser.new.get(url) )
  end
end
