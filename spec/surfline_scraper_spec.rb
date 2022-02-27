require_relative './spec_helper'
require_relative '../lib/surfline_scraper'

describe SurflineScraper, vcr: { cassette_name: 'surfline_scraper' } do
  subject(:scraper){ SurflineScraper.new }

  before { Timecop.freeze(Time.local(2021, 1, 26, 11, 03)) }
  after { Timecop.return }

  describe '#initialize' do
    it 'defaults the URL to Cocoa Beach if none given' do
      expect( scraper.url ).to match( /cocoa-beach-pier/ )
    end
  end

  its(:updated_at){ should be_within(120).of(Chronic.parse('February 26, 2022 at 6:56 am')) }
  its(:wave_range){ should eq '2-3 ft' }
  its(:wave_description){ should eq 'Thigh to waist' }
  its(:spot_conditions){ should eq 'fair' }
  its(:spot_conditions_report){ should match(/^<p><strong>Central/i) }
  its(:spot_conditions_report){ should_not match(/Forecast Headlines/i) }
end

xdescribe SurflineScraper, vcr: { cassette_name: 'surfline_scraper_flat' } do
  subject(:scraper){ SurflineScraper.new }

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
