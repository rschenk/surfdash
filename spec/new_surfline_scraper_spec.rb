require_relative './spec_helper'
require_relative '../lib/new_surfline_scraper'

describe NewSurflineScraper, vcr: { cassette_name: 'new_surfline_scraper' } do
  subject(:scraper){ NewSurflineScraper.new }

  before { Timecop.freeze(Time.local(2021, 1, 26, 11, 03)) }
  after { Timecop.return }

  describe '#initialize' do
    it 'defaults the URL to Cocoa Beach if none given' do
      expect( scraper.url ).to match( /cocoa-beach-pier/ )
    end
  end

  its(:updated_at){ should eq Chronic.parse('January 28, 2022 at 1:19:42pm') }
  its(:wave_range){ should eq '2-3 ft' }
  its(:wave_description){ should eq 'Waist to stomach high' }
  its(:spot_conditions){ should eq 'fair' }
  its(:spot_conditions_report){ should match(/^<p><strong>Central/i) }
  its(:spot_conditions_report){ should_not match(/Forecast Headlines/i) }
end

xdescribe NewSurflineScraper, vcr: { cassette_name: 'new_surfline_scraper_flat' } do
  subject(:scraper){ NewSurflineScraper.new }

  before { Timecop.freeze(Time.local(2018, 06, 04, 20, 30)) }
  after { Timecop.return }

  describe '#initialize' do
    it 'defaults the URL to Cocoa Beach if none given' do
      expect( scraper.url ).to match( /cocoa-beach-pier/ )
    end
  end

  its(:updated_at){ should eq Chronic.parse('June 4, 2018 at 1pm') }
  its(:wave_range){ should eq 'Flat' }
  its(:wave_description){ should eq 'Flat' }
  its(:spot_conditions){ should eq 'flat' }
  its(:spot_conditions_report){ should match(/^<p><strong>CENTRAL/) }
end
