require 'webrick'
require_relative '../lib/bonus/controller_base'
require_relative '../lib/bonus/router'

class Hat
  attr_accessor :name
  
  def initialize(name)
    @name = name
  end
end

class HatsController < Bonus::ControllerBase
  def new
    render :new
  end
  
  def create
    redirect_to "/hats"
  end
  
  def index
    @hats = [Hat.new("Top Hat"), Hat.new("Baseball Cap")]
    render :index
  end
  
  def link_test
    render :link_test
  end
end

router = Bonus::Router.new
router.draw do
  get Regexp.new("^/hats$"), HatsController, :index
  get Regexp.new("^/hats/new$"), HatsController, :new
  get Regexp.new("^/link_test$"), HatsController, :link_test
  post Regexp.new("^/hats$"), HatsController, :create
end

router.add_shortcut("hats", "/hats")
router.add_shortcut("new_hat", "/hats/new")
router.add_shortcut("link_test", "/link_test")

server = WEBrick::HTTPServer.new(Port: 3000)
server.mount_proc('/') do |req, res|
  route = router.run(req, res)
end

trap('INT') { server.shutdown }
server.start
