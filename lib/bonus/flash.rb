module Bonus
  class Flash
    def initialize(req)
      cookie = req.cookies.find { |c| c.name == '_rails_lite_app_flash'}
      @flash = JSON.parse(cookie.value) if cookie
      @flash ||= {}
      @next_flash = {}
    end
    
    def [](key)
      @flash[key]
    end
    
    def []=(key, val)
      @next_flash[key] = val
    end
    
    def now
      @flash
    end
    
    def store_flash(res)
      res.cookies.delete_if { |c| c.name == '_rails_lite_app_flash' }
      cookie = WEBrick::Cookie.new('_rails_lite_app_flash', @next_flash.to_json)
      res.cookies << cookie
    end
  end
end