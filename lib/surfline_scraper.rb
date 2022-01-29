require_relative './browser'
require 'nokogiri'
require 'chronic'

class SurflineScraper
  attr_accessor :url

  def initialize(url=nil)
    @url = url || 'https://www.surfline.com/surf-report/cocoa-beach-pier/5842041f4e65fad6a7708872'
  end

  def updated_at
    @updated_at ||= Time.at(
       spot_report_data(%w[report timestamp])
    )
  end

  def wave_range
    @wave_range ||= (
      min = spot_report_data(%w[forecast waveHeight min])
      max = spot_report_data(%w[forecast waveHeight max])
      "#{min}-#{max} ft"
    )
  end

  def wave_description
    @wave_description ||= spot_report_data(%w[forecast waveHeight humanRelation])
  end

  def spot_conditions
    @spot_conditions ||= spot_report_data(%w[forecast conditions value]).to_s.downcase
  end

  def spot_conditions_report
    @spot_conditions_report ||= (
      spot_report_data("report", "body")
        .to_s
        .gsub("<p><br></p>", "")
    )
  end

  private

  def doc
    @doc ||= Nokogiri::HTML( Browser.new.get(url) )
  end

  def report_json
    return @report_json unless @report_json.nil?

    data_tag = doc.xpath("//script[starts-with(text(),'window.__DATA__')]").first
    json_text = data_tag.text.gsub(/\A\s*window.__DATA__\s*=\s*/, '')

    @report_json = JSON.parse(json_text)
  end
  
  def spot_report_data(*args)
    report_json.dig(*(["spot", "report", "data"] + args).flatten)
  end
end
