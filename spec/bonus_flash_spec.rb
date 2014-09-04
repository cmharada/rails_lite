require 'webrick'
require 'bonus/flash'
require 'bonus/controller_base'

describe Bonus::Flash do
  let(:req) { WEBrick::HTTPRequest.new(Logger: nil) }
  let(:req2) { WEBrick::HTTPRequest.new(Logger: nil) }
  let(:res) { WEBrick::HTTPResponse.new(HTTPVersion: '1.0') }
  let(:cook) { WEBrick::Cookie.new('_rails_lite_app_flash', { xyz: 'abc' }.to_json) }

  it "deserializes json cookie if one exists" do
    req.cookies << cook
    flash = Bonus::Flash.new(req)
    flash['xyz'].should == 'abc'
  end
  
  it "doesn't return future flash values" do
    req.cookies << cook
    flash = Bonus::Flash.new(req)
    flash['future'] = 'a'
    flash['future'].should_not == 'a'
  end
  
  it "does not keep old flash data" do
    req.cookies << cook
    flash = Bonus::Flash.new(req)
    flash.store_flash(res)
    cookie = res.cookies.find { |c| c.name == '_rails_lite_app_flash' }
    req2.cookies << cookie
    new_flash = Bonus::Flash.new(req2)
    new_flash['xyz'].should_not == 'abc'
  end
  
  describe 'flash#now' do
    it "allows access to flash.now" do
      flash = Bonus::Flash.new(req)
      flash['nothing'].should == nil
      flash.now['nothing'] = "Hello"
      flash['nothing'].should == "Hello"
    end
    
    it "does not save flash.now objects" do
      flash = Bonus::Flash.new(req)
      flash.now['abc'] = "Hello"
      flash.store_flash(res)
      cookie = res.cookies.find { |c| c.name == '_rails_lite_app_flash' }
      req2.cookies << cookie
      new_flash = Bonus::Flash.new(req2)
      new_flash['abc'].should_not == 'Hello'
    end
  end
end

describe Bonus::ControllerBase do
  before(:all) do
    class CatsController < Bonus::ControllerBase
    end
  end
  after(:all) { Object.send(:remove_const, "CatsController") }
  
  let(:req) { WEBrick::HTTPRequest.new(Logger: nil) }
  let(:res) { WEBrick::HTTPResponse.new(HTTPVersion: '1.0') }
  let(:cats_controller) { CatsController.new(req, res) }
  let(:cook) { WEBrick::Cookie.new('_rails_lite_app_flash', { xyz: 'abc' }.to_json) }

  describe "#flash" do
    it "returns a flash instance" do
      expect(cats_controller.flash).to be_a(Bonus::Flash)
    end

    it "returns the same instance on successive invocations" do
      first_result = cats_controller.flash
      expect(cats_controller.flash).to be(first_result)
    end
  end

  shared_examples_for "storing flash data" do
    it "should store the flash data" do
      req.cookies << cook
      cats_controller.flash['test_key'] = 'test_value'
      cats_controller.flash['xyz'].should == 'abc'
      cats_controller.send(method, *args)
      cookie = res.cookies.find { |c| c.name == '_rails_lite_app_flash' }
      h = JSON.parse(cookie.value)
      expect(h['test_key']).to eq('test_value')
    end
    
    it "shouldn't store the old data" do
      req.cookies << cook
      cats_controller.send(method, *args)
      cookie = res.cookies.find { |c| c.name == '_rails_lite_app_flash' }
      h = JSON.parse(cookie.value)
      expect(h['xyz']).to_not eq('abc')
    end
  end

  describe "#render_content" do
    let(:method) { :render_content }
    let(:args) { ['test', 'text/plain'] }
    include_examples "storing flash data"
  end

  describe "#redirect_to" do
    let(:method) { :redirect_to }
    let(:args) { ['http://appacademy.io'] }
    include_examples "storing flash data"
  end
end
