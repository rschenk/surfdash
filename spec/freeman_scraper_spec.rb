require_relative './spec_helper'
require_relative '../lib/freeman_scraper'

describe FreemanScraper, vcr: { cassette_name: 'freeman_sunday' } do
  subject(:scraper){ FreemanScraper.new }

  describe '#initialize' do
    it 'defaults the URL to the pier report' do
      expect( scraper.url ).to match( /gosurfsportswear.com/ )
    end
  end

  its(:updated_at){ should eq Chronic.parse('Sunday, Apr 12th at 6:30 am') }
  its(:conditions){ should eq 'Small and Weak for DPrs' }
  its(:conditions_report){ should eq 'Looking knee- to rare waist-high with junky, broken lines. Early Southerly winds will become southeasterly before noon' }

  its(:pier_conditions){ should eq 'Thigh-high with ugly crappy slop' }
  its(:pier_conditions_report){ should eq 'should improve some thru incoming high tide' }

  its(:pafb_conditions){ should eq 'Looking thigh-high to waist-high and a lil cleaner down this way' }
  its(:pafb_conditions_report){ should eq 'will need to find high tide friendly sandbars by mid morning' }

  its(:pier_sb_rating){ should eq 1 }
  its(:pier_lb_rating){ should eq 2 }
  its(:pafb_sb_rating){ should eq 2 }
  its(:pafb_lb_rating){ should eq 2 }
end
