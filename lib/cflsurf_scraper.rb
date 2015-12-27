require_relative './browser'
require 'nokogiri'
require 'chronic'

class CflsurfScraper
  attr_accessor :url
  attr_accessor :doc

  def initialize(url=nil)
    @url = url || 'http://cflsurf.com/aa-outlook.txt'
  end

  def updated_at
    @updated_at ||= scrape_updated_at
  end

  def forecast
    @forecast ||= doc.css('p').xpath('text()').map(&:text).join(' ').strip
  end

  private

  def doc
    @doc ||= load_doc
  end

  def load_doc
    # Load URL
    str = Browser.new.get(url).read

    # That URL is some kinda Javascript dealy with HTML embedded in a string
    regex = /OutlookText = "(.*?)"$/
    html = regex.match( str.strip ){ |m| m[1].strip }

    # Parse HTML fragment
    Nokogiri::HTML::fragment(html)
  end

  def scrape_updated_at
    str = doc.css('b').text
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
