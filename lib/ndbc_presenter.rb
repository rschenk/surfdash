class NdbcPresenter < SimpleDelegator
  def dom_id
    [
      'buoy',
      station_id.to_s.gsub(/\W+/, '_')
    ].join('_')
  end

  def url
    "https://www.ndbc.noaa.gov/station_page.php?station=#{station_id}"
  end

  def updated_at_string
    @updated_at_string ||= updated_at.strftime( updated_at_format )
  end

  def wave_height
    @wave_height ||= '%.1f' % super
  end

  def average_period
    @average_period ||= super.round
  end

  def swell_time_series
    super(hours: 24*3)
  end

  private

  def updated_at_format
    date_format = if updated_at.to_date == Date.today
                    'Today'
                  else
                    '%A, %B %-d'
                  end

    if updated_at.is_a? Date
      date_format
    else
      "#{ date_format } at %-l:%M %P"
    end
  end
end
