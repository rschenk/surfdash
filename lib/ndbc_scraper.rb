require_relative './browser'
require_relative './convert'
require 'rubygems'
require 'smarter_csv'

class NdbcScraper
  include Convert 

  attr_accessor :station_id

  def initialize(station_id='41113', url=nil)
    @station_id = station_id
    @url = url
  end

  def most_recent_reading
    @most_recent_reading ||= parsed_data.first
  end

  def parsed_data
    @parsed_data ||= parse_data
  end

  def updated_at
    most_recent_reading['time']
  end

  def wave_height
    m_to_ft most_recent_reading['WVHT']
  end

  def dominant_period
    most_recent_reading['DPD']
  end

  def average_period
    most_recent_reading['APD']
  end

  def direction
    deg_to_human most_recent_reading['MWD']
  end

  def water_temp
    c_to_f most_recent_reading['WTMP']
  end

  def swell_time_series(hours: 24)
    cutoff = updated_at - (hours * 60 * 60)

    parsed_data
      .lazy
      .filter { |row| row['time'] >= cutoff }
      .map { |row| [row['time'], m_to_ft(row['WVHT']), row['DPD'], row['APD'], deg_to_human(row['MWD'])] }
      .sort_by { |time, _height| time }
  end

  private

  def url
    @url ||= "https://www.ndbc.noaa.gov/data/realtime2/#{station_id}.txt"
  end

  def load_data
    Browser.new.get(url)
  end

  def parse_data
    SmarterCSV.process(
      load_data,
      col_sep: /\s+/,
      comment_regexp: /^#/,
      remove_empty_hashes: true,
      header_transformations: [:none],
      hash_transformations: [
        remove_missing_wave_values,
        :convert_values_to_numeric,
        convert_date_columns_to_date_object,
      ]
    )
  end

  def remove_missing_wave_values
    @remove_missing_wave_values ||= Proc.new{|hash, args=nil|
      next {} if %w(WVHT DPD APD)
                    .map { |k| hash[k] }
                    .any? { |v| v == 'MM' }
      hash
    }
  end

  def convert_date_columns_to_date_object
    @convert_date_columns_to_date_object ||= Proc.new{|hash, args=nil|
      next {} unless hash.key?('YY') # We remove missing wave values before this

      hash['time'] = Time.utc(
        hash['YY'], hash['MM'], hash['DD'], hash['hh'], hash['mm']
      ).getlocal
      hash
    }
  end

  def deg_to_human(deg)
    val = ((deg/22.5)+0.5).to_i
    directions = ["N","NNE","NE","ENE","E","ESE", "SE", "SSE","S","SSW","SW","WSW","W","WNW","NW","NNW"]
    directions[val % 16]
  end
end
