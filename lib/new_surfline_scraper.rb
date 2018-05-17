require_relative './browser'
require 'nokogiri'
require 'chronic'

class NewSurflineScraper
  attr_accessor :url

  def initialize(url=nil)
    @url = url || 'https://www.surfline.com/surf-report/cocoa-beach-pier/5842041f4e65fad6a7708872'
  end

  def updated_at
    return @updated_at unless @updated_at.nil?

    updated_at_text = doc.
      at_css('.sl-forecaster-profile__update-container__last-update').
      children.
      select { |child| child.text? }.
      map(&:text).
      join(' ').
      strip

    updated_at = Chronic.parse(updated_at_text, context: :past )

    # Due to how surfline writes their dates, Chronic gets confused and thinks
    # today is either a week ago
    if Date.today - updated_at.to_date == 7
      updated_at += 604800 # 1.week
    end

    @updated_at ||= updated_at
  end

  def wave_range
    @wave_range ||= doc
      .at_css('.sl-spot-forecast-summary__wrapper .quiver-surf-height')
      .text
      .strip
      .gsub(/(?<!\s)FT/, ' ft')
  end

  def wave_description
    @wave_description ||= doc
    .at_css('.sl-spot-forecast-summary__wrapper .sl-reading-description[data-reactid="1029"]')
    .text
    .strip
  end

  def spot_conditions
    @spot_conditions ||= doc.at_css('.sl-spot-report .sl-colored-condition-bar').text.strip.downcase
  end

  def spot_conditions_report
    @spot_conditions_report ||= doc.css('.sl-spot-report__report-text p').
      reject{|p| p.text.strip.empty? }.
      reject{|p| p.text.match /Check out\s+Premium Analysis\s+for more details/i }.
      map{|p| p.inner_html.strip }.
      map{|p| "<p>#{p}</p>" }.
      join
  end

  private

  def doc
    @doc ||= Nokogiri::HTML( Browser.new.get(url) )
  end

end
