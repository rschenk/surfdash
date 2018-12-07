require_relative './spec_helper'
require_relative '../lib/surfline_county_presenter'
require_relative '../lib/surfline_county_scraper'

describe SurflineCountyPresenter::Spot do
  let(:presenter){ SurflineCountyPresenter::Spot.new( scraper_double ) }
  let(:scraper_double){ instance_double 'SurflineCountyScraper::Spot' }

  describe '#conditions_class' do
    before{ allow(scraper_double).to receive(:conditions).and_return('poor to fair' ) }
    it 'replaces all non-word characters with dashes' do
      expect(presenter.conditions_class).to eq 'poor-to-fair'
    end
  end

  describe '#wave_range' do
    before{ allow(scraper_double).to receive(:wave_range).and_return('2-3 ft+') }
    it 'removes the units' do
      expect(presenter.wave_range).to eq '2-3+'
    end
  end

  describe '#id' do
    before{ allow(scraper_double).to receive(:name).and_return('16th St. South' ) }
    it 'replaces all non-word characters with dashes' do
      expect(presenter.id).to eq '16th-st-south'
    end
  end
end

describe SurflineCountyPresenter do
  let(:presenter){ SurflineCountyPresenter.new( scraper_double ) }
  let(:scraper_double){ instance_double 'SurflineCountyScraper' }

  describe '#spots' do
    before { allow(scraper_double).to receive(:spots).and_return([instance_double('SurflineCountyScraper::Spot')]) }
    it 'decorates each original spot' do
      expect(presenter.spots.first).to be_a SurflineCountyPresenter::Spot
    end
  end
end
