require 'time'
require_relative './spec_helper'
require_relative '../lib/freeman_presenter'

describe FreemanPresenter do

  let(:presenter){ FreemanPresenter.new( scraper ) }
  let(:scraper){ instance_double('FreemanScraper') }

  describe '#updated_at_string' do

    context 'when #updated_at is today' do
      before{ allow(scraper).to receive(:updated_at).and_return( Time.now ) }

      it 'matches "Today at 7:45 am"' do
        expect( presenter.updated_at_string ).to match(/Today at \d\d?:\d\d [a|p]m/)
      end
    end

    context 'when #updated_at is in the past' do
      before{ allow(scraper).to receive(:updated_at).and_return( time_in_past ) }
      let(:time_in_past){ Time.parse('2015-04-09 09:42:37 -0400') }

      it 'matches "Thursday, April 9 at 9:42 am"' do
        expect( presenter.updated_at_string ).to eq 'Thursday, April 9 at 9:42 am'
      end
    end

  end

  describe '#seen_it_already?' do
    before do
      allow( scraper ).to receive(:updated_at).
        and_return( Time.now - 100 )
    end

    it 'returns true when last_viewed_at > updated_at' do
      presenter.last_viewed_at = Time.now - 10
      expect( presenter.seen_it_already? ).to be true
    end

    it 'returns false when last_viewed_at < updated_at' do
      presenter.last_viewed_at = Time.now - 1000
      expect( presenter.seen_it_already? ).to be false
    end
  end

  describe '#seen_it_already_class' do
    subject{ presenter.seen_it_already_class }

    context 'when we have seen it already' do
      before{ allow( presenter ).to receive(:seen_it_already?).and_return(true) }
      it{ is_expected.to eq 'seen-it-already' }
    end

    context 'when we have not seen it already' do
      before{ allow( presenter ).to receive(:seen_it_already?).and_return(false) }
      it{ is_expected.to be nil }
    end
  end

  describe '#conditions' do
    it 'conjoins the conditions and conditions report with punctuation' do
      allow(scraper).to receive(:conditions).and_return('Small and Weak for DPrs.')
      allow(scraper).to receive(:conditions_report).and_return('Looking knee- to rare waist-high with junky, broken lines. Early Southerly winds will become southeasterly before noon')

      expect( presenter.conditions ).to eq "#{scraper.conditions_report}. #{scraper.conditions}"
    end
  end


end

