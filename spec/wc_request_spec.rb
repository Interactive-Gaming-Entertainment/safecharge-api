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
    'total_amount' => 15.0,
    'currency' => 'USD',
    'items' => [
      { 'name' => 'ball',
        'number' => 'sku12345',
        'amount' => 15,
        'quantity' => 1,
        'open_amount' => 'true',
        'min_amount' => 10,
        'max_amount' => 200} ],
    'user_token_id' => 'yayfortokens'
  } }

  let(:full_params) {
    params.merge({
      'user_token' => 'auto',
      'customData' => 'something',
      'customSiteName' => 'My Amazing Webshop',
      'discount' => 0,
      'encoding' => 'UTF-8',
      'error_url' => 'oops.html',
      'handling' => 0,
      'invoice_id' =>  'bill_me_1',
      'merchant_id' => 123456,
      'merchant_site_id' => 12345,
      'merchant_unique_id' => 'some_unique_username',
      'merchantLocale' => 'en_GB',
      'payment_method' => 'cc_card',
      'pending_url' => 'pending.html',
      'productId' => '0987654321',
      'shipping' => 0,
      'skip_billing_tab' => 'true',
      'skip_review_tab' => 'false',
      'success_url' => 'yay.html',
      'total_tax' => 0,
      'userid' => 'some_unique_username',
      'webMasterId' => 'test',
      'state' => 'ny', # ISO code
      'zip' => '555667', # post code
      'address1' => 'Bunkum Building',
      'address2' => '99 55th Street'
    })
  }

  describe "positive tests" do
    it "should create a request with minimal params" do
  		req = Safecharge::WcRequest.new(Safecharge::Constants::SERVER_TEST, params)
      req.should_not eq nil
      req.full_url.should_not eq req.url
    end

    it "should create a request when called from the top with minimal params" do
      url = Safecharge.wc_request_url(params)
      url.should_not eq nil
    end

    it "should create a request with maxed out params" do
  		req = Safecharge::WcRequest.new(Safecharge::Constants::SERVER_TEST, full_params)
      req.should_not eq nil
      req.full_url.should_not eq req.url
    end

    it "should create a request when called from the top with maxed out params" do
      url = Safecharge.wc_request_url(full_params)
      url.should_not eq nil
    end
  end
  
  describe "negative guests" do
    it "should fail create a request when called from the top with bad mode" do
      expect {Safecharge.wc_request_url(params, 'yeehaaa')}.to raise_error ArgumentError
    end

    it "should fail to create a request with a bad url" do
      expect {Safecharge::WcRequest.new('bad_url')}.to raise_error ArgumentError
    end
  end
end

