require_relative './spec_helper'
require_relative '../lib/freeman_scraper'

describe FreemanScraper, vcr: { cassette_name: 'freeman_scraper' } do
  subject(:scraper){ FreemanScraper.new }

  describe '#initialize' do
    it 'defaults the URL to the pier report' do
      expect( scraper.url ).to match( /gosurfsportswear.com/ )
    end
  end

  its(:updated_at){ should eq Chronic.parse('Sunday, Nov 10th at 6:30 am') }
  its(:conditions){ should eq 'N wind early, kinda bumpy and drifty for DPrs' }
  its(:conditions_report){ should eq 'thigh to Waist high+' }

  its(:pier_conditions){ should eq 'semi-clean longboard lines this morning, sum bigger sets' }
  its(:pier_conditions_report){ should eq 'Mostly thigh-high' }

  its(:pafb_conditions){ should eq 'bumpy, kinda drifty' }
  its(:pafb_conditions_report){ should eq 'more waist-high+ waves down this way.' }

  its(:pier_sb_rating){ should eq 1 }
  its(:pier_lb_rating){ should eq 3 }
  its(:pafb_sb_rating){ should eq 4 }
  its(:pafb_lb_rating){ should eq 2 }
end
