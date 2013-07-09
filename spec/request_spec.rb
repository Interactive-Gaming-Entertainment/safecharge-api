#!/user/bin/env ruby
#coding: utf-8

require "safecharge"
require "safecharge/constants"
require "safecharge/request"

describe Safecharge::Request do

  before :each do

    @params = {
      'merchant_id' => 4797923801005868286,
      'merchant_site_id' => 37501,
      'total_amount' => 15,
      'currency' => 'USD',
      'items' => [
        { 'name' => 'ball',
          'number' => 'sku12345',
          'amount' => 15,
          'quantity' => 1} ]
    }

  end

  it "should create a request" do

		req = Safecharge::Request.new(Safecharge::Constants::SERVER_TEST, @params)
    req.should_not eq nil
    req.full_url.should_not eq req.url
  end

  it "should create a request when called from the top" do
    url = Safecharge.request_url(@params)
    url.should_not eq nil
  end

  it "should fail create a request when called from the top with bad mode" do
    expect {Safecharge.request_url(@params, 'yeehaaa')}.to raise_error ArgumentError
  end

  it "should fail to create a request with a bad url" do
    expect {Safecharge::Request.new('bad_url')}.to raise_error ArgumentError
  end

  it "should fail to create a request with bad input" do
    params = { }
		expect {Safecharge::Request.new(Safecharge::Constants::SERVER_TEST, params)}.to raise_error Safecharge::ValidationException
    params.merge!({'merchant_id' => 4797923801005868286})
		expect {Safecharge::Request.new(Safecharge::Constants::SERVER_TEST, params)}.to raise_error Safecharge::ValidationException
    params.merge!({'merchant_site_id' => 37501})
		expect {Safecharge::Request.new(Safecharge::Constants::SERVER_TEST, params)}.to raise_error Safecharge::ValidationException
    params.merge!({'total_amount' => 15})
		expect {Safecharge::Request.new(Safecharge::Constants::SERVER_TEST, params)}.to raise_error Safecharge::ValidationException
    item = {'name' => 'ball'}
    params.merge!({'items' => [item]})
		expect {Safecharge::Request.new(Safecharge::Constants::SERVER_TEST, params)}.to raise_error Safecharge::ValidationException
    item.merge!({'number' => 'sku12345'})
    params.merge!({'items' => [item]})
		expect {Safecharge::Request.new(Safecharge::Constants::SERVER_TEST, params)}.to raise_error Safecharge::ValidationException
    item.merge!({'amount' => "ten"})
    params.merge!({'items' => [item]})
		expect {Safecharge::Request.new(Safecharge::Constants::SERVER_TEST, params)}.to raise_error Safecharge::ValidationException
    item.merge!({'amount' => 15})
    params.merge!({'items' => [item]})
		expect {Safecharge::Request.new(Safecharge::Constants::SERVER_TEST, params)}.to raise_error Safecharge::ValidationException
    item.merge!({'quantity' => 1})
    params.merge!({'items' => [item]})
		expect {Safecharge::Request.new(Safecharge::Constants::SERVER_TEST, params)}.to_not raise_error

    params.merge!({'nonsense' => 'not here please'})
		expect {Safecharge::Request.new(Safecharge::Constants::SERVER_TEST, params)}.to raise_error Safecharge::ValidationException
    
    item.merge!({'unknown' => "whatsallthisthen?"})
    params.merge!({'items' => [item]})
		expect {Safecharge::Request.new(Safecharge::Constants::SERVER_TEST, params)}.to raise_error Safecharge::InternalException
  end

end
