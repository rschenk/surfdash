require 'tempfile'
require 'chronic'
require_relative './ocr'
require_relative './browser'

class CheckthewavesScraper
  attr_accessor :url
  attr_writer :buoy_text # dependency injection for testing

  def initialize
    @url = 'https://checkthewaves.com/images/incomingdata/Cocoa_Beach_summary.png'
  end

  def updated_at
    @updated_at ||= scrape_updated_at
  end

  def wave_height
    scrape_data
    @wave_height
  end

  def peak_period
    scrape_data
    @peak_period
  end

  def water_temp_bottom
    scrape_data
    @water_temp_bottom
  end

  def buoy_text
    @buoy_text ||= load_buoy_text
  end

  private

  def compacted_text
    @compacted_text ||= buoy_text.gsub(/\n+/, "\n")
  end

  def text_lines
    @text_lines ||= compacted_text.split("\n").map{|line| line.strip }
  end

  # The data exists after the line "Check The Waves"
  def data_lines
    return @data_lines if @data_lines
    idx = text_lines.map(&:downcase).index('check the waves')
    @data_lines = text_lines.slice(idx + 1, text_lines.length)
  end

  def scrape_updated_at
    date = text_lines[1].
             gsub(/[^\/\d]/, '') # Remove anything not part of the datestamp
    time = text_lines[2].
            gsub(/(?<=\d)\s(?=\d)/, ':'). # Sometimes OCR misses the colons between HH:MM:SS
            gsub(/[^:|\d]/, '') # Remove anything that isn't part of the timestamp proper

    month, day, year = date.split('/')
    hour, minute, second = time.split(':')

    Time.utc(year, month, day, hour, minute, second).getlocal
  end

  def scrape_data
    @wave_height = data_lines[0]
    @peak_period = tweak_period(data_lines[1])
    @water_temp_bottom = data_lines[2]
  end

  # OCR likes to interpret "9.1 s" as "9.15"
  def tweak_period(period)
    period.sub(/5$/, ' s')
  end



  def load_buoy_text
    tempfile = Tempfile.new('checkthewaves')
    begin
      Browser.new.save(url, tempfile)
      OCR.new(tempfile).text.to_s.strip
    ensure
      tempfile.close
      tempfile.unlink
    end
  end
end

