require_relative './spec_helper'
require_relative '../lib/cflsurf_scraper'

describe CflsurfScraper, vcr: { cassette_name: 'cflsurf_scraper' } do
  subject(:scraper){ CflsurfScraper.new }

  describe '#initialize' do
    it 'defaults the URL to Cocoa Beach if none given' do
      expect( scraper.url ).to match( /cflsurf.com/ )
    end
  end

  its(:updated_at){ should eq Date.parse( '2015-08-16' ) }
  its(:forecast){ should match(/It doesn't look like we will be surfing much/) }

  describe '#updated_at' do
    context 'when a date and time are given' do
      before do
        scraper.doc = Nokogiri::HTML::fragment( 'OutlookText = "<p><b> Sept 3 (Thurs 6:15 AM) - </b> Knee high or less thru the weekend. Nothing on the radar at the moment."' )
      end

      it 'returns a Time object' do
        Timecop.freeze( Time.local(2015, 9, 3, 12, 0, 0) ) do
          expect( scraper.updated_at ).to eq Time.local( 2015, 9, 3, 6, 15, 00 )
        end
      end
    end

    context 'when a date but no time is given' do
      before do
        scraper.doc = Nokogiri::HTML::fragment( %(OutlookText = "<p><b> Aug 16 (Sun) - </b> It doesn't look like we will be surfing much this weekend or the coming week either.") )
      end

      it 'returns a Date object' do
        Timecop.freeze( Time.local(2015, 9, 3, 12, 0, 0) ) do
          expect( scraper.updated_at ).to eq Date.new( 2015, 8, 16 )
        end
      end
    end
  end
end
