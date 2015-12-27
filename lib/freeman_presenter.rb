require 'yaml/store'

class FreemanPresenter < SimpleDelegator

  attr_accessor :last_viewed_at
  attr_accessor :store

  def conditions
    [ conditions_report, super ].map{|s| punctuate(s) }.join(' ')
  end

  def seen_it_already?
    last_viewed_at > updated_at
  end

  def seen_it_already_class
    'seen-it-already' if seen_it_already?
  end

  def updated_at_string
    @updated_at_string ||= updated_at.strftime( updated_at_format )
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

  def punctuate(str)
    str.sub(/\W$/,'') << '.'
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
