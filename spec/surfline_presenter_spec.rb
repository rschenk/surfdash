require 'time'
require_relative './spec_helper'
require_relative '../lib/surfline_presenter'

describe SurflinePresenter do

  let(:presenter){ SurflinePresenter.new( scraper_double ) }
  let(:scraper_double){ double('SurflineScraper double') }

  describe '#updated_at_string' do

    context 'when #updated_at is today' do
      before{ allow(scraper_double).to receive(:updated_at).and_return( Time.now ) }

      it 'matches "Today at 7:45 am"' do
        expect( presenter.updated_at_string ).to match(/Today at \d\d?:\d\d [a|p]m/)
      end
    end

    context 'when #updated_at is in the past' do
      before{ allow(scraper_double).to receive(:updated_at).and_return( time_in_past ) }
      let(:time_in_past){ Time.parse('2015-04-09 09:42:37 -0400') }

      it 'matches "Thursday, April 9 at 9:42 am"' do
        expect( presenter.updated_at_string ).to eq 'Thursday, April 9 at 9:42 am'
      end
    end

  end

  describe '#spot_conditions_class' do
    before{ allow(scraper_double).to receive(:spot_conditions).and_return('poor to fair Conditions' ) }

    it 'replaces all non-word characters with dashes' do
      expect( presenter.spot_conditions_class ).to eq 'poor-to-fair-conditions'
    end

  end

end
