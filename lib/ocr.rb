class OCR
  attr_reader :file

  def initialize(file_or_path)
    @file = file_or_path.respond_to?(:path) ? file_or_path : File.new(file_or_path)
  end

  def text
    @text ||= do_ocr
  end

  private

  def do_ocr
    output = IO.popen("tesseract '#{file.path}' stdout")
    output.read
  end
end
