require_relative './spec_helper'
require_relative '../lib/freeman_scraper'

describe FreemanScraper, vcr: { cassette_name: 'freeman_scraper' } do
  subject(:scraper){ FreemanScraper.new }

  describe '#initialize' do
    it 'defaults the URL to the pier report' do
      expect( scraper.url ).to match( /gosurfsportswear.com/ )
    end
  end

  its(:updated_at){ should eq Chronic.parse('Sunday, Dec 30th at 6:30 am') }
  its(:conditions){ should eq 'early southwesterly breeze' }
  its(:conditions_report){ should eq 'thigh to Waist high clean lines' }

  its(:pier_conditions){ should eq 'small but clean longboard lines' }
  its(:pier_conditions_report){ should eq 'Mostly Thigh high, sum bigger' }

  its(:pafb_conditions){ should eq 'clean lines' }
  its(:pafb_conditions_report){ should eq 'mostly waist high' }

  its(:pier_sb_rating){ should eq 1 }
  its(:pier_lb_rating){ should eq 5 }
  its(:pafb_sb_rating){ should eq 3 }
  its(:pafb_lb_rating){ should eq 5 }
end
