require 'bundler/setup'
require 'sinatra'
require 'sinatra/json'
require './lib/xtide'
require './lib/new_surfline_scraper'
require './lib/surfline_presenter'
require './lib/surfline_county_scraper'
require './lib/surfline_county_presenter'
require './lib/cflsurf_scraper'
require './lib/cflsurf_presenter'
require './lib/freeman_scraper'
require './lib/freeman_presenter'
require './lib/checkthewaves_scraper'
require './lib/checkthewaves_presenter'
require './lib/ndbc_scraper'
require './lib/ndbc_presenter'

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
  # mock_request('new_surfline_scraper')

  erb :surfline, locals: { surfline: SurflinePresenter.new(NewSurflineScraper.new) }
end


get '/surfline-county' do
  # mock_request('surfline_county_scraper')

  erb :surfline_county, locals: { surfline_county: SurflineCountyPresenter.new(SurflineCountyScraper.new) }
end

get '/cflsurf' do
  # mock_request('cflsurf_scraper')

  erb :cflsurf, locals: { cflsurf: CflsurfPresenter.new(CflsurfScraper.new) }
end

get '/freeman' do
  # mock_request('freeman_scraper')

  erb :freeman, locals: { freeman: FreemanPresenter.new(FreemanScraper.new) }

end

get '/checkthewaves' do
  erb :checkthewaves, locals: { checkthewaves: CheckthewavesPresenter.new(CheckthewavesScraper.new) }
end

get '/weather' do
  weather = JSON.parse Browser.new.get('https://api.nextgen.guardianapps.co.uk/weatherapi/city/2230945.json?_edition=us').read
  weather['html']
end

get '/buoy_41113' do
  # mock_request('ndbc_scraper_web') do
    erb :ndbc, locals: {
      title: 'Canaveral Nearshore',
      buoy: NdbcPresenter.new(NdbcScraper.new(41113))
    }
  # end
end

get '/buoy_41009' do
  # mock_request('ndbc_scraper_web') do
    erb :ndbc, locals: {
      title: 'Canaveral 20 Mile',
      buoy: NdbcPresenter.new(NdbcScraper.new(41009))
    }
  # end
end

def mock_request(cassette_name, &block)
  require 'vcr'

  VCR.configure do |config|
    config.cassette_library_dir = File.expand_path('../spec/fixtures/vcr', __FILE__ )
    config.hook_into :webmock
  end

  VCR.use_cassette(cassette_name, &block)
end
