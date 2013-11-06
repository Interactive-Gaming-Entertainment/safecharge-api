#!/user/bin/env ruby
#coding: utf-8

require "safecharge"
require "safecharge/constants"
require "safecharge/request"
require 'spec_helper'

describe Safecharge::WcRequest do

  let(:params) { {
    'first_name' => 'John',
    'last_name' => 'Citizen',
    'city' => 'New York',
    'country' => 'USA',
    'total_amount' => 15,
    'currency' => 'USD',
    'items' => [
      { 'name' => 'ball',
        'number' => 'sku12345',
        'amount' => 15,
        'quantity' => 1,
        'open_amount' => 'true',
        'min_amount' => 100,
        'max_amount' => 200} ],
    'user_token_id' => 'yayfortokens'
  } }

  it "should create a request" do

		req = Safecharge::WcRequest.new(Safecharge::Constants::SERVER_TEST, params)
    req.should_not eq nil
    req.full_url.should_not eq req.url
  end

  it "should create a request when called from the top" do
    url = Safecharge.wc_request_url(params)
    url.should_not eq nil
  end

  it "should fail create a request when called from the top with bad mode" do
    expect {Safecharge.wc_request_url(params, 'yeehaaa')}.to raise_error ArgumentError
  end

  it "should fail to create a request with a bad url" do
    expect {Safecharge::WcRequest.new('bad_url')}.to raise_error ArgumentError
  end

end

