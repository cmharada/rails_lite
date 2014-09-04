require_relative '../phase6/router'

module Bonus
  class Route < Phase6::Route  
    def run(req, res, shortcuts = {})
      keys = @pattern.named_captures
      vals = @pattern.match(req.path).captures
      route_params =  { }
      keys.each do |key, val|
        route_params[key] = vals[val.first - 1]
      end
      controller = @controller_class.new(req, res, route_params)
      shortcuts.each do |name, url|
        controller.add_url_shortcut(name, url)
      end
      controller.invoke_action(@action_name)
    end
  end
  
  class Router < Phase6::Router
    def initialize
      super
      @shortcuts = {}
    end
    
    def add_shortcut(name, url)
      @shortcuts[name] = url
    end
    
    def add_route(pattern, method, controller_class, action_name)
      @routes << Route.new(pattern, method, controller_class, action_name)
      #Consider - Automatic URL Shortcuts?
    end
    
    def run(req, res)
      route = match(req)
      if route
        route.run(req, res, @shortcuts)
      else
        res.status = 404
        res.body = "No Route Found"
      end
    end
  end
end