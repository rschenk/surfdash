require 'yaml/store'

class SurflinePresenter < SimpleDelegator

  attr_reader :last_viewed_at

  def initialize(*args)
    super

    store.transaction do
      @last_viewed_at = store[ :last_viewed_at ]

      store[:last_viewed_at] = Time.now
    end
  end

  def seen_it_already?
    last_viewed_at && last_viewed_at > updated_at
  end

  def seen_it_already_class
    'seen-it-already' if seen_it_already?
  end

  def updated_at_string
    @updated_at_string ||= updated_at.strftime( updated_at_format )
  end

  def spot_conditions_class
    spot_conditions.downcase.gsub(/\W+/, '-')
  end

  private

  def store
    @store ||= YAML::Store.new('db/surfdash.yml')
  end

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
