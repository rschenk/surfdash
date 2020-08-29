require_relative './spec_helper'
require_relative '../lib/ndbc_scraper'

describe NdbcScraper, vcr: { cassette_name: 'ndbc_scraper' } do
  subject(:scraper){ described_class.new(41009) }

  describe '#initialize' do
    it 'defaults the station id to Canaveral Nearshore if none given' do
      expect( described_class.new.station_id ).to eq '41113'
    end
  end

  its(:updated_at){ should eq Chronic.parse('June 12 2020 at 11:50 AM') }
  its(:wave_height) { should be_within(0.01).of(3.28) }
  its(:dominant_period) { should eq 7 }
  its(:average_period) { should be_within(0.1).of(4.6) }
  its(:water_temp) { should be_within(0.1).of(80.7) }
  its(:direction) { should eq 'E' }

  describe '#swell_time_series' do
    subject(:series) { scraper.swell_time_series }

    it 'returns back the last 24 hours of wave height data' do
      expect(series.length).to be <= 49 # readings every half hour

      expect(series.first[0]).to be_within(1).of(Chronic.parse('June 11 2020 at 11:50 AM'))
      expect(series.last[0]).to be_within(1).of(Chronic.parse('June 12 2020 at 11:50 AM'))

      expect(series.first[1]).to be_within(0.1).of(2.9) # Height
      expect(series.first[2]).to eq 6 # Period
    end
  end
end

describe NdbcScraper, vcr: { cassette_name: 'ndbc_scraper_with_url' } do
  subject(:scraper){ described_class.new(41009, 'https://www.ndbc.noaa.gov/data/5day2/41009_5day.txt') }

  context 'with optional url' do
    its(:updated_at){ should eq Chronic.parse('July 11 2020 at 9:50am') }
    its(:wave_height) { should be_within(0.01).of(2.30) }
    its(:dominant_period) { should eq 10 }
    its(:average_period) { should be_within(0.1).of(4.2) }
    its(:water_temp) { should be_within(0.1).of(83.1) }
    its(:direction) { should eq 'E' }

    describe '#swell_time_series' do
      subject(:series) { scraper.swell_time_series }

      it 'returns back the last 24 hours of wave height data' do
        expect(series.length).to be <= 49 # readings every half hour

        expect(series.first[0]).to be_within(1).of(Chronic.parse('July 10 2020 at 22:50'))
        expect(series.last[0]).to be_within(1).of(Chronic.parse('July 11 2020 at 9:50 AM'))

        expect(series.first[1]).to be_within(0.1).of(1.9) # Height
        expect(series.first[2]).to eq 9 # Period
      end
    end
  end
end
