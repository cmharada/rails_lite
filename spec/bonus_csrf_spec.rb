require 'webrick'
require 'bonus/controller_base'

describe Bonus::ControllerBase do
  before(:all) do
    class HatsController < Bonus::ControllerBase
      def dummy
        render :dummy
      end
    end
  end
  after(:all) { Object.send(:remove_const, "HatsController") }
  
  let(:req) { WEBrick::HTTPRequest.new(Logger: nil) }
  let(:res) { WEBrick::HTTPResponse.new(HTTPVersion: '1.0') }
  let(:hats_controller) { HatsController.new(req, res) }
  
  it "generates a csrf token" do
    hats_controller.form_authenticity_token.should be_a(String)
  end
  
  it "randomizes the token" do
    token = hats_controller.form_authenticity_token
    hats_controller.form_authenticity_token.should_not == token
  end
  
  context "submitting forms" do
    it "does not allow forms to be submitted without a token" do
      req.stub(:request_method) { "POST" }
      hatscontroller2 = HatsController.new(req, res)
      expect do
        hatscontroller2.invoke_action(:dummy)
      end.to raise_error "CSRF ATTACK DETECTED"
    end
    
    it "allows submission of forms with a token" do
      token = "abc"
      req.stub(:request_method) { "POST" }
      req.stub(:query_string) { "authenticity_token=#{ token }"}
      hatscontroller2 = HatsController.new(req, res)
      hatscontroller2.session["form_authenticity_token"] = token
      expect do
        hatscontroller2.invoke_action(:dummy)
      end.not_to raise_error
    end
  end
end