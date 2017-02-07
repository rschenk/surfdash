require_relative './spec_helper'
require_relative '../lib/surfline_scraper'

describe SurflineScraper, vcr: { cassette_name: 'surfline_scraper' } do
  subject(:scraper){ SurflineScraper.new }

  describe '#initialize' do
    it 'defaults the URL to Cocoa Beach if none given' do
      expect( scraper.url ).to match( /cocoa.beach/ )
    end
  end

  its(:updated_at){ should eq Chronic.parse('February 7 2017 at 7:33 AM') }
  its(:wave_range){ should eq '1-2 ft' }
  its(:wave_description){ should match(/knee/) }
  its(:spot_conditions){ should eq 'poor conditions' }
  its(:spot_conditions_report){ should match(/^<p><strong>CENTRAL/) }
end
