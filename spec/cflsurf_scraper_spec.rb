# -*- coding: utf-8 -*-
require_relative './spec_helper'
require_relative '../lib/cflsurf_scraper'

describe CflsurfScraper, vcr: { cassette_name: 'cflsurf_scraper' } do
  subject(:scraper){ CflsurfScraper.new }

  describe '#initialize' do
    it 'defaults the URL to Cocoa Beach if none given' do
      expect( scraper.url ).to match( /cflsurf.com/ )
    end
  end

  its(:updated_at){ should eq Date.parse( '2017-04-21' ) }

  its(:forecast) do
    should eq([
      OpenStruct.new(timestamp: Date.parse('2017-11-10'), forecast: '2-4ft chop surf with N to NNE wind winds at 15MPH+'),
      OpenStruct.new(timestamp: Date.parse('2017-11-11'), forecast: '5-7ft surf with NE winds clocking at 25MPH, 2pm High tide if you are looking for mid-breaks and shore-pound'),
    OpenStruct.new(timestamp: Date.parse('2017-11-12'), forecast: '5-6ft surf with NE winds at 20MPH, the wind fetch stretches up to Maine, so the underlying ground swell should provide some long lefts if your willing to paddle out. A drift session may be the call.')
    ])
  end


  describe '#parse_time' do
    context 'when a date and time are given' do
      it 'returns a Time object' do
        Timecop.freeze( Time.local(2015, 9, 3, 12, 0, 0) ) do
          expect( scraper.parse_time('Sept 3 (Thurs 6:15 AM)') ).to eq Time.local( 2015, 9, 3, 6, 15, 00 )
        end
      end
    end

    context 'when a date but no time is given' do
      it 'returns a Date object' do
        Timecop.freeze( Time.local(2015, 9, 3, 12, 0, 0) ) do
          expect( scraper.parse_time('Aug 16 (Sun)') ).to eq Date.new( 2015, 8, 16 )
        end
      end
    end
  end
end
