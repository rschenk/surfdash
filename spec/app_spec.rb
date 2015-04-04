require_relative './spec_helper'

describe 'My app' do
  it 'serves up the dashboard page' do
    get '/'
    expect( last_response ).to be_ok
  end

  it 'provides json data for the tide graph' do
    get '/tide.json'
    expect( last_response ).to be_ok
    expect( last_response.content_type ).to eq 'application/json'

    json = JSON.parse( last_response.body )

    expect( json['start']  ).not_to be_nil
    expect( json['end']    ).not_to be_nil
    expect( json['now']    ).not_to be_nil
    expect( json['events'] ).not_to be_nil
    expect( json['graph']  ).not_to be_nil
  end
end
