require 'webrick'
require 'bonus/controller_base'

describe Bonus::ControllerBase do
  before(:all) do
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
  
      def index
        @hats = [Hat.new("Top Hat"), Hat.new("Baseball Cap")]
        render :index
      end
      
      def link_test
        render :link_test
      end
      
      def url_test
        render :url_test
      end
      
      def url_test2
        render :url_test2
      end
    end
  end
  after(:all) do 
    Object.send(:remove_const, "HatsController")
    Object.send(:remove_const, "Hat")
  end
  
  let(:req) { WEBrick::HTTPRequest.new(Logger: nil) }
  let(:res) { WEBrick::HTTPResponse.new(HTTPVersion: '1.0') }
  let(:hats_controller) { HatsController.new(req, res) }
  
  before(:each) do
    req.stub(:request_method) { "get" }
  end

  describe "url helper" do
    it "can accept url helper methods" do
      hats_controller.add_url_shortcut("arbitrary", "/link_test")
      hats_controller.invoke_action(:url_test)
      res.body.should include("/link_test")
    end
    
    it "can accept params in the url helper methods" do
      hats_controller.add_url_shortcut("arbitrary", "/link_test")
      hats_controller.invoke_action(:url_test2)
      res.body.should include("/link_test/10")
    end
  end
  
  describe "partial views" do
    it "renders a partial" do
      hats_controller.invoke_action(:new)
      res.body.should include("This text is in the partial")
    end
  
    it "renders a partials, with local variables" do
      hats_controller.invoke_action(:index)
      res.body.should include("Top Hat")
    end
  end
  
  it "supports the link_to helper" do
    hats_controller.invoke_action(:link_test)
    res.body.should include("a href")
  end
  
  it "supports the button_to helper" do
    hats_controller.invoke_action(:link_test)
    res.body.should include("form action=")
  end
end