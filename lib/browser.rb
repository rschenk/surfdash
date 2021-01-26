require 'open-uri'

class Browser
  attr_reader :url,
              :user_agent

  def initialize(user_agent=nil)
    @user_agent = user_agent || default_user_agent
  end

  def get(url)
    open(url, 'User-Agent' => user_agent)
  end

  def save(url, file)
    File.open(file, 'wb') do |f|
      f.write( get(url).read )
    end
  end

  private

  def default_user_agent
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.2 Safari/605.1.15'
  end
end
