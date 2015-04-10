require 'open-uri'
require 'nokogiri'
require 'chronic'

class SurflineScraper
  attr_accessor :url
  attr_accessor :user_agent

  def initialize(url=nil)
    @url = url || 'http://www.surfline.com/surf-report/cocoa-beach-pier-florida_4421/'
    @user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.75.14 (KHTML, like Gecko) Version/7.0.3 Safari/7046A194A'
  end

  def updated_at
    @updated_at ||= Chronic.parse(
      doc.at_css('#observed-wave-range').
      parent.children.
      find{|n| n.text =~ /updated/ }.
      first_element_child.
      text.strip
    )
  end

  def wave_range
    @wave_range ||= doc.at_css('#observed-wave-range').text.strip
  end

  def wave_description
    @wave_description ||= doc.at_css('#observed-wave-description').text.strip
  end

  def spot_conditions
    @spot_conditions ||= doc.at_css('#observed-spot-conditions').text.strip
  end

  def spot_conditions_report
    @spot_conditions_report ||= doc.at_css('#observed-spot-conditions-summary p').inner_html
  end

  private

  def doc
    @doc ||= Nokogiri::HTML( open( url, 'User-Agent' => user_agent ))
  end

end
