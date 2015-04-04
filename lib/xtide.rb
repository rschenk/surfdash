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
      CSV.parse( output ) do |location, date, time, height, event_type|

        timestamp = Time.parse( "#{date} #{time}" )

        # Constrain data to only within our start and end times
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
      CSV.parse( output ) do |location, epoch, height|

        timestamp = Time.at( epoch.to_i )

        # Constrain data to only within our start and end times
        # plus a little extra to make sure the graph is smooth on the ends
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

    _, epoch, height = output.strip.split(',')

    [ Time.at( epoch.to_i ), height.to_f ]
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
