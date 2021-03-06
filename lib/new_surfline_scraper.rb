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

    updated_at_text = report_element
      .at_css('.quiver-forecaster-profile__update-container__last-update')
      .children
      .select { |child| child.text? }
      .map(&:text)
      .join(' ')
      .strip

    updated_at = Chronic.parse(updated_at_text, context: :past )

    # Due to how surfline writes their dates, Chronic gets confused and thinks
    # today is either a week ago
    if Date.today - updated_at.to_date == 7
      updated_at += 604800 # 1 week
    end

    @updated_at ||= updated_at
  end

  def wave_range
    @wave_range ||= report_element
      .at_css('.quiver-surf-height')
      .text
      .strip
      .gsub(/(?<!\s)FT/, ' ft')
  end

  def wave_description
    @wave_description ||= report_element
      .at_css('.quiver-reading-description')
      .text
      .strip
  end

  def spot_conditions
    @spot_conditions ||= report_element
      .at_css('.quiver-colored-condition-bar')
      .text
      .strip
      .downcase
  end

  def spot_conditions_report
    return @spot_conditions_report if @spot_conditions_report

    paragraphs = report_element
      .css('.quiver-spot-report__report-text p')
      .lazy
      .reject{|p| p.text.strip.empty? }
      .reject{|p| p.text.match /Check out\s+Premium Analysis\s+for more details/i }
      .take_while{|p| !p.text.match /Forecast Headlines/i }
      .map{|p| p.inner_html.strip }
      .map{|p| "<p>#{p}</p>" }
      .to_a
      .join

    @spot_conditions_report = paragraphs
  end

  private

  def doc
    @doc ||= Nokogiri::HTML( Browser.new.get(url) )
  end

  def report_element
    @report_element ||= doc.at_css('.quiver-spot-report')
  end

end
