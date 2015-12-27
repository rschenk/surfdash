require 'bundler/setup'
require 'sinatra'
require 'sinatra/json'
require './lib/xtide'
require './lib/surfline_scraper'
require './lib/surfline_presenter'
require './lib/cflsurf_scraper'
require './lib/cflsurf_presenter'
require './lib/freeman_scraper'
require './lib/freeman_presenter'

get '/' do
  erb :index
end

get '/tide.json' do
  xtide = Xtide.new

  json({
    start: xtide.start_t,
    end: xtide.end_t,
    now: xtide.now,
    events: xtide.events,
    graph: xtide.graph_data
  })
end

get '/surfline' do
  # require 'vcr'
  #
  # VCR.configure do |config|
  #   config.cassette_library_dir = File.expand_path('../spec/fixtures/vcr', __FILE__ )
  #   config.hook_into :webmock
  # end
  #
  # VCR.insert_cassette('surfline_scraper')

  erb :surfline, locals: { surfline: SurflinePresenter.new(SurflineScraper.new) }
end

get '/cflsurf' do
  # require 'vcr'
  #
  # VCR.configure do |config|
  #   config.cassette_library_dir = File.expand_path('../spec/fixtures/vcr', __FILE__ )
  #   config.hook_into :webmock
  # end
  #
  # VCR.insert_cassette('cflsurf_scraper')

  erb :cflsurf, locals: { cflsurf: CflsurfPresenter.new(CflsurfScraper.new) }
end


get '/freeman' do
  # require 'vcr'
  #
  # VCR.configure do |config|
  #   config.cassette_library_dir = File.expand_path('../spec/fixtures/vcr', __FILE__ )
  #   config.hook_into :webmock
  # end
  #
  # VCR.insert_cassette('freeman_scraper')

  erb :freeman, locals: { freeman: FreemanPresenter.new(FreemanScraper.new) }

end
