require_relative './browser'
require 'nokogiri'
require 'chronic'

class SurflineScraper
  attr_accessor :url

  def initialize(url=nil)
    @url = url || 'http://www.surfline.com/surf-report/cocoa-beach-pier-florida_4421/'
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
    @wave_description ||= doc.at_css('#observed-wave-description').text.gsub(/^-/, '').strip
  end

  def spot_conditions
    @spot_conditions ||= doc.at_css('#observed-spot-conditions').text.strip.downcase
  end

  def spot_conditions_report
    @spot_conditions_report ||= doc.css('#observed-spot-conditions-summary p').
      map{|p| p.inner_html.strip }.
      reject{|p| p.empty? }.
      reject{|p| p.start_with? "<strong>Please note</strong>" }.
      map{|p| "<p>#{p}</p>" }.
      join
  end

  private

  def doc
    @doc ||= Nokogiri::HTML( Browser.new.get(url) )
  end

end
