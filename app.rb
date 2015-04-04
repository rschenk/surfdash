require 'bundler/setup'
require 'sinatra'
require 'sinatra/json'
require './lib/xtide'

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
