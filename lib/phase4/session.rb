require 'json'
require 'webrick'

module Phase4
  class Session
    # find the cookie for this app
    # deserialize the cookie into a hash
    def initialize(req)
      cookie = req.cookies.find { |c| c.name == '_rails_lite_app'}
      @hash = JSON.parse(cookie.value) if cookie
      @hash ||= {}
    end

    def [](key)
      @hash[key.to_s]
    end

    def []=(key, val)
      @hash[key.to_s] = val
    end

    # serialize the hash into json and save in a cookie
    # add to the responses cookies
    def store_session(res)
      cookie = WEBrick::Cookie.new('_rails_lite_app', @hash.to_json)
      cookie.path = "/"
      res.cookies << cookie
    end
  end
end
