require_relative '../phase6/controller_base'
require_relative './flash'

module Bonus
  class ControllerBase < Phase6::ControllerBase
    def redirect_to(url)
      super(url)
      self.flash.store_flash(@res)
    end

    def render_content(content, type)
      super(content, type)
      self.flash.store_flash(@res)
    end

    # method exposing a `Flash` object
    def flash
      @flash ||= Flash.new(@req)
    end
    
    def form_authenticity_token
      token = SecureRandom.urlsafe_base64(16)
      session[:form_authenticity_token] = token
      token
    end
    
    def add_url_shortcut(name, url)
      singleton_class.send(:define_method, "#{ name }_url") do |param = nil|
        if param
          if param.is_a?(Fixnum)
            "#{ url }/#{ param.to_s }"
          else
            "#{ url }/#{ param.id }"
          end
        else
          url
        end
      end
    end
    
    def link_to(name, url)
      "<a href = '#{ url }'>#{ name }</a>"
    end
    
    def button_to(name, url)
      "<form action='#{ url }' method='post'>
        <input type='hidden'
          name='authenticity_token'
          value='#{ form_authenticity_token }'>
        <input type='submit' value='#{ name }'>
      </form>"
    end
    
    def invoke_action(name)
      unless @req.request_method.downcase == "get"
        raise "CSRF ATTACK DETECTED" unless
          @params["authenticity_token"] &&
          session[:form_authenticity_token] == @params["authenticity_token"]
      end
      send(name)
      render(name) unless already_built_response?
    end
    
    def render(template_name)
      template_path = "views/#{ self.class.name.underscore }/#{ template_name }.html.erb"
      template = File.read(template_path)
      render_content(ERB.new(template).result(binding), "text/html")
    end
    
    def render_partial(template_name, local_vars = {})
      template_path = "views/#{ self.class.name.underscore }/_#{ template_name }.html.erb"
      template = File.read(template_path)
      namespace = LocalVars.new(local_vars)
      ERB.new(template).result(namespace.get_binding)
    end
  end
  
  class LocalVars
    def initialize(hash)
      hash.each do |key, val|
        singleton_class.send(:define_method, key) { val }
      end
    end
    
    def get_binding
      binding
    end
  end
end