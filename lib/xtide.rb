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

  def execute( options='' )
    `HFILE_PATH=#{hfile_path} #{path}/tide #{default_arguments} #{options}`
  end

  private

  def load_events
    output = execute "-m p -b '#{stftime(start_t)}' -e '#{stftime(end_t)}'"

    [].tap do |events|
      CSV.parse( output ) do |location, date, time, height, event_type|

        timestamp = Time.parse( "#{date} #{time}" )

        # Only interested in high and low tide events, not sun/moon
        next unless event_type.match(/tide/i)

        events << [
          timestamp,
          height.to_f,
          event_type
        ]

      end
    end
  end

  def load_graph_data
    time_padding = 60*60 # one hour padding on times to ensure smooth graph ends
    graph_start = start_t - time_padding
    graph_end   = end_t   + time_padding

    interval = '00:30' # HH:MM

    output = execute "-m r -s '#{interval}' -b '#{stftime(graph_start)}' -e '#{stftime(graph_end)}'"

    [].tap do |graph_data|
      CSV.parse( output ) do |location, epoch, height|

        timestamp = Time.at( epoch.to_i )

        graph_data << [
          timestamp,
          height.to_f
        ]
      end
    end
  end

  def load_now
    now = Time.now
    next_minute = now + 60
    output = execute "-m r -b '#{stftime(now)}' -e '#{stftime(next_minute)}'"
    first_line, *_ = output.split("\n")

    _location, epoch, height = first_line.strip.split(',')

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

  def hfile_path
    path + '/localTCD/harmonics-dwf-20190620-free.tcd'
  end

  def stftime(time)
    time.strftime('%Y-%m-%d %H:%M')
  end
end
