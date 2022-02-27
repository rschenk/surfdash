require_relative './spec_helper'
require_relative '../lib/surfline_county_scraper'

describe SurflineCountyScraper, vcr: { cassette_name: 'surfline_county_scraper' } do
  subject(:scraper){ described_class.new }

  describe '#initialize' do
    it 'defaults the URL to Brevard if none given' do
      expect( scraper.url ).to match( /brevard/ )
    end
  end

  its(:spots) { should include SurflineCountyScraper::Spot.new('Cocoa Beach Pier', '2-3 ft', 'fair') }
  its(:spots) { should include SurflineCountyScraper::Spot.new('Hightower Beach', '3-4 ft', 'fair') }
end
