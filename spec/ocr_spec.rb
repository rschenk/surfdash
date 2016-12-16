require_relative './spec_helper'
require_relative '../lib/ocr.rb'

describe OCR do
  subject(:ocr){ OCR.new(file) }
  let(:path){ File.open(File.expand_path('../fixtures/images/Cocoa_Beach_summary.png', __FILE__)) }
  let(:file){ File.open(path) }

  describe '#initialize' do
    it 'accepts a path to an image' do
      expect( OCR.new(path).file.path ).to eq file.path
    end
    it 'accepts a File to an image' do
      expect( OCR.new(file).file.path ).to eq file.path
    end
  end

  describe '#text' do
    it 'returns the OCR of the image' do
      expect(ocr.text.strip).to start_with 'Current Ocean Conditions'
    end
  end
end
