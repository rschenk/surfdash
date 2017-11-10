require_relative './browser'
require 'nokogiri'
require 'chronic'
require 'ostruct'

class CflsurfScraper
  attr_accessor :url
  attr_accessor :doc

  def initialize(url=nil)
    @url = url || 'http://cflsurf.com/io/'
  end

  def updated_at
    @updated_at ||= scrape_updated_at
  end

  def forecast
    @forecast ||= scrape_forecast_nodes
  end

  private

  def doc
    @doc ||= Nokogiri::HTML( Browser.new.get(url) )
  end

  def scrape_forecast_nodes
    forecast_nodes.map do |node|
      timestamp_text = node.css('b').text
      timestamp = parse_time(timestamp_text) rescue next
      forecast = node.inner_text.
        sub(timestamp_text, '').
        gsub(/^[[:space:]]+/, '').
        gsub(/[[:space]]+$/, '')
      OpenStruct.new(timestamp: timestamp, forecast: forecast)
    end.compact
  end

  def scrape_updated_at
    forecast.first.timestamp
  end

  def forecast_nodes
    @forecast_nodes ||= doc.css('#content > .wpb_row:first-of-type p')
  end

  public

  def parse_time(str)
    date_regex = /^(\w+)\s+(\d+)/
    time_regex = /\(.*?(\d+:\d+ [A|P]M)\)/i

    _, month, day = date_regex.match(str.strip){ |m| m.to_a }
    _, time       = time_regex.match(str.strip){ |m| m.to_a }

    parsed_time = Chronic.parse "#{month} #{day} #{time}".strip, context: :past

    if time.nil?
      parsed_time.to_date
    else
      parsed_time
    end
  end


end
