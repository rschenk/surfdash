require_relative './spec_helper'
require_relative '../lib/browser'

describe Browser, vcr: { cassette_name: 'browser' } do
  subject(:browser){ Browser.new }

  describe '#initialize' do
    it 'defaults the user agent to a sane one' do
      expect(Browser.new.user_agent).to match(/Mozilla/)
    end
  end

  describe '#get' do
    context 'given a url' do
      let(:url){ 'http://cflsurf.com/' }

      it 'returns a StringIO of the source' do
        expect(browser.get(url).read).to match(/<html/)
      end
    end
  end
end
