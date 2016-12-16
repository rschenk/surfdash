require_relative './spec_helper'
require_relative '../lib/checkthewaves_scraper'

describe CheckthewavesScraper, vcr: { cassette_name: 'checkthewaves_scraper' } do
  subject(:scraper){ CheckthewavesScraper.new }

  describe '#initialize' do
    it 'defaults the URL to Cocoa Beach if none given' do
      expect(scraper.url).to match(/Cocoa_Beach_summary/)
    end
  end

  describe 'accessors' do
    before do
      subject.buoy_text = "Current Ocean Conditions at Cocoa_Beach\n\nDate 12/16/2016\nTime 20 30 00 UTC\n(Time 15:30:00 EST)\nWave Height\nPeak Period\nWaterTemperature on Bottom\nWaterTemperature on Surface\n\nWater Depth at Wavegauge\n\ninformation provided by\nCheck The Waves\n\n1.9 ft\n\n9.15\n\n69.6 F\n\n32.1 ft"
    end

    its(:updated_at){ should eq Time.utc(2016,12,16,20,30,00) }
    its(:wave_height){ should eq '1.9 ft' }
    its(:peak_period){ should eq '9.1 s' }
    its(:water_temp_bottom){ should eq '69.6 F' }
  end
end
