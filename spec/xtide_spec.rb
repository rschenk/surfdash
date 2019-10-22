require_relative './spec_helper'

describe Xtide do
  subject(:xtide){ Xtide.new }

  let( :midnight_this_morning ) { Date.today.to_time }
  let( :midnight_tonight      ) { Date.today.next_day.to_time }

  describe '#start_t' do
    it 'returns the beginning of the current day' do
      expect( xtide.start_t ).to eq midnight_this_morning
    end
  end

  describe '#end_t' do
    it 'returns midnight tomorrow' do
      expect( xtide.end_t ).to eq midnight_tonight
    end
  end

  describe '#now' do
    let(:now) { xtide.now }

    it 'returns a tuple of timestamp and current tide level' do
      expect( now ).to be_a Array
      expect( now[0] ).to be_within( 60 ).of( Time.now )
      expect( now[1] ).to be_a Float
    end
  end

  describe '#events' do
    it 'returns high and low tide events between start and end times' do
      expect(xtide.events).not_to be_empty

      xtide.events.each do |event|
        expect( event[0] ).to be_between( midnight_this_morning, midnight_tonight )
        expect( event[1] ).to be_a Float
        expect( event[2] ).to match( /High|Low/ )
      end
    end
  end

  describe '#graph_data' do
    it 'returns a 2D array of timestamp and current level tuples' do
      xtide.graph_data.each do |datum|
        expect( datum[0] ).to be_a Time
        expect( datum[1] ).to be_a Float
      end
    end

    it 'constrains times between start and end times, with a little padding' do

      an_hour = 60*60

      xtide.graph_data.each do |datum|
        expect( datum[0] ).to be_between(
          midnight_this_morning - an_hour,
          midnight_tonight      + an_hour
        )
      end

    end
  end
end
