require_relative './spec_helper'
require_relative '../lib/new_surfline_scraper'

describe NewSurflineScraper, vcr: { cassette_name: 'new_surfline_scraper' } do
  subject(:scraper){ NewSurflineScraper.new }

  before { Timecop.freeze(Time.local(2018, 05, 16, 20, 30)) }
  after { Timecop.return }

  describe '#initialize' do
    it 'defaults the URL to Cocoa Beach if none given' do
      expect( scraper.url ).to match( /cocoa-beach-pier/ )
    end
  end

  its(:updated_at){ should eq Chronic.parse('May 16, 2018 at 1pm') }
  its(:wave_range){ should eq '2-3 ft' }
  its(:wave_description){ should eq 'Knee to waist high' }
  its(:spot_conditions){ should eq 'poor' }
  its(:spot_conditions_report){ should match(/^<p><strong>CENTRAL/) }
end
