class SurflinePresenter < SimpleDelegator

  def updated_at_string
    @updated_at_string ||= updated_at.strftime( updated_at_format )
  end

  def spot_conditions_class
    spot_conditions.downcase.gsub(/\W+/, '-')
  end

  private

  def updated_at_format
    date_format = if date_updated == Date.today
                    'Today at'
                  else
                    '%A, %B %-d at'
                  end

    "#{ date_format } %-l:%M %P"
  end

  def date_updated
    @date_updated ||= Date.parse( updated_at.to_s )
  end
end
