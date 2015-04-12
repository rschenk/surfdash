require 'open-uri'
require 'nokogiri'
require 'chronic'

class BobFreemanScraper
  attr_accessor :url
  attr_accessor :user_agent

  attr_reader :conditions
  attr_reader :conditions_report
  attr_reader :pier_conditions
  attr_reader :pier_conditions_report
  attr_reader :pafb_conditions
  attr_reader :pafb_conditions_report

  def initialize(url=nil)
    @url = url || 'http://www.gosurfsportswear.com/piercam/pier.html'
    @user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.75.14 (KHTML, like Gecko) Version/7.0.3 Safari/7046A194A'

    load_page
  end

  def updated_at
    @updated_at ||= Chronic.parse(  lines.first + " at 6:30 am" )
  end

  def pier_sb_rating
    @pier_sb_rating ||= report_td.text.match(/^CB Pier SB rating.*?(\d+)/)[1].to_i
  end

  def pier_lb_rating
    @pier_lb_rating ||= report_td.text.match(/^CB Pier\s+LB rating.*?(\d+)/)[1].to_i
  end

  def pafb_sb_rating
    @pafb_sb_rating ||= report_td.text.match(/^PAFB-MelBch\s+SB rating.*?(\d+)/)[1].to_i
  end

  def pafb_lb_rating
    @pafb_lb_rating ||= report_td.text.match(/^PAFB-MelBch\s+LB rating.*?(\d+)/)[1].to_i
  end

  private

  def lines
    @lines ||= report_td.inner_html.split('<br>').map{|s| striptags(s).strip }
  end

  def report_td
    @report_td ||= doc.css('td[background="tl13.jpg"]')
  end

  def doc
    @doc ||= Nokogiri::HTML( open( url, 'User-Agent' => user_agent ))
  end

  def striptags(str)
    Nokogiri::HTML(str).text
  end

  def load_page
    load_report
    load_pier_report
    load_pafb_report
  end

  def load_report
    match_data = report_td.inner_html.match(/DP Peek\.\.\.(.*?)Pier\.\.\./m)
    fragment = Nokogiri::HTML::fragment( match_data[1] )

    @conditions = fragment.search('i').text.strip
    @conditions_report = fragment.xpath('text()').map(&:text).join(' ').strip
  end

  def load_pier_report
    match_data = report_td.inner_html.match(/Pier\.\.\.(.*?)PAFB/m)
    fragment = Nokogiri::HTML::fragment( match_data[1] )

    @pier_conditions = fragment.search('i').text.strip
    @pier_conditions_report = fragment.at_css('font').xpath('text()').map(&:text).join(' ').strip
  end

  def load_pafb_report
match_data = report_td.inner_html.match(/PAFB-MelBch\.\.\.(.*?)^<br>... check/m)
    fragment = Nokogiri::HTML::fragment( match_data[1] )

    @pafb_conditions = fragment.search('i').text.strip
    @pafb_conditions_report = fragment.at_css('font').xpath('text()').map(&:text).join(' ').strip
  end

end
