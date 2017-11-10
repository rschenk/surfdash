require 'yaml/store'

class CflsurfPresenter < SimpleDelegator

  attr_accessor :last_viewed_at
  attr_accessor :store

  def forecast
    super.map do |forecast_line|
      %(<p class="forecast-item"><span class="timestamp">#{format_date forecast_line.timestamp}</span> <span class="forecast">#{forecast_line.forecast}</span></p>)
    end.join("\n")
  end

  def seen_it_already?
    last_viewed_at > updated_at
  end

  def seen_it_already_class
    'seen-it-already' if seen_it_already?
  end

  def updated_at_string
    @updated_at_string ||= format_date(updated_at)
  end

  def last_viewed_at
    return @last_viewed_at unless @last_viewed_at.nil?

    store.transaction do
      key = [ self.class.name, 'last_viewed_at' ].join('_').to_sym

      @last_viewed_at = store[ key ]

      store[ key ] = Time.now
    end

    @last_viewed_at
  end

  def store
    @store ||= YAML::Store.new('db/surfdash.yml')
  end

  private

  def format_date(date)
    date_format = if date.to_date == Date.today
                    'Today'
                  else
                    '%A, %B %-d'
                  end

    format_string = if date.is_a? Date
                      date_format
                    else
                      "#{ date_format } at %-l:%M %P"
                    end
    date.strftime(format_string)
  end

end
