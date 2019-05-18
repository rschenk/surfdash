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
    doc.css('.sl-spot-list__spots .quiver-spot-list-item__container')
      .map { |spot| scrape_spot spot }
      .uniq { |spot| spot.name }
  end

  def scrape_spot(el)
    name = el.css('.quiver-spot-details__name').text.strip
    conditions = el.css('.quiver-surf-conditions').first.text.strip.downcase
    wave_range = el.css('.quiver-surf-height')
      .text
      .strip
      .gsub(/(?<!\s)FT/, ' ft')

    Spot.new(name, wave_range, conditions)
  end

  def doc
    @doc ||= Nokogiri::HTML( Browser.new.get(url) )
  end
end
