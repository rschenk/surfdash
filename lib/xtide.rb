require 'time'
require 'csv'

class Xtide

  attr_accessor :location
  attr_accessor :start_t
  attr_accessor :end_t

  def initialize(location=nil)
    @location = location || 'Cocoa Beach, Florida'
    @start_t  = Date.today.to_time
    @end_t    = Date.today.next_day.to_time
  end

  def events
    @events ||= load_events
  end

  def graph_data
    @graph_data ||= load_graph_data
  end

  def now
    @now ||= load_now
  end

  def basic_command
    "cd #{path}; ./tide #{default_arguments}"
  end

  private

  def load_events
    [].tap do |events|

      output = `#{basic_command} -m p`
      CSV.parse( output ) do |row|
        location, date, time, height, event_type = row

        timestamp = Time.parse( "#{date} #{time}" )
        next  if timestamp < start_t
        break if timestamp > end_t

        events << [
          timestamp,
          height.to_f,
          event_type
        ]

      end
    end
  end

  def load_graph_data
    interval = '00:30' # HH:MM
    output = `#{basic_command} -m r -s "#{interval}"`

    padding = 60*60 # one hour

    [].tap do |graph_data|
      CSV.parse( output ) do |row|
        location, epoch, height = row

        timestamp = Time.at( epoch.to_i )
        next  if timestamp < ( start_t - padding )
        break if timestamp > ( end_t   + padding )

        graph_data << [
          timestamp,
          height.to_f
        ]
      end
    end
  end

  def load_now
    output = `#{basic_command} -m n`

    location, epoch, height = output.strip.split(',')

    [ Time.at( epoch.to_i ), height.to_f ]
  end

  def midnight
    @midnight ||= Date.today.to_time
  end

  def tomorrow
    @tomorrow ||= Date.today.next_day.to_time
  end

  def default_arguments
    <<-ARGS.strip.gsub( /\s+/, ' ' )
      -l "#{location}"
      -f c
    ARGS
  end

  def path
    @path ||= File.expand_path("../../bin", __FILE__)
  end

end
