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

  private

  def default_user_agent
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.75.14 (KHTML, like Gecko) Version/7.0.3 Safari/7046A194A'
  end
end
