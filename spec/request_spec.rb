#!/user/bin/env ruby
#coding: utf-8

require "safecharge"
require "safecharge/constants"
require "safecharge/request"
require 'spec_helper'

describe Safecharge::Request do

  let(:params) { { 
    'total_amount' => 25,
    'currency' => 'USD',
    'items' => [
      { 'name' => 'ball',
        'number' => 'sku12345',
        'amount' => 25,
        'quantity' => 1} ]
  } }
  
  let(:sym_params) { { 
    total_amount: 25,
    currency: 'USD',
    items: [
      { name: 'ball',
        number: 'sku12345',
        amount: 25,
        quantity: 1} ]
  } }

  let(:full_params) {
    params.merge({
      'customData' => 'something',
      'customSiteName' => 'My Amazing Webshop',
      'discount' => 12.5,
      'encoding' => 'UTF-8',
      'error_url' => 'oops.html',
      'handling' => 5.55,
      'invoice_id' =>  'bill_me_1',
      'merchant_id' => 123456,
      'merchant_site_id' => 12345,
      'merchant_unique_id' => 'some_unique_username',
      'merchantLocale' => 'en_GB',
      'payment_method' => 'cc_card',
      'pending_url' => 'pending.html',
      'productId' => '0987654321',
      'shipping' => 11.11,
      'skip_billing_tab' => 'true',
      'skip_review_tab' => 'false',
      'success_url' => 'yay.html',
      'total_amount' => (25.0 + 5.55 + 11.11 - 12.5),
      'total_tax' => 0,
      'userid' => 'some_unique_username',
      'webMasterId' => 'test',
      'first_name' => 'Bob',
      'last_name' => 'Brown',
      'city' => 'Bristol',
      'country' => 'gb',
      'state' => '', # ISO code
      'zip' => 'BS1', # post code
      'address1' => '99 Kings Lane',
      'address2' => ''
    })
  }
  
  describe "positive tests" do
    it "should create a request with minimal params" do
  		req = Safecharge::Request.new(Safecharge::Constants::SERVER_TEST, params)
      req.should_not eq nil
      req.full_url.should_not eq req.url
    end

    it "should create a request with minimal symbol params" do
  		req = Safecharge::Request.new(Safecharge::Constants::SERVER_TEST, sym_params)
      req.should_not eq nil
      req.full_url.should_not eq req.url
    end

    it "should create a request with all params" do
  		req = Safecharge::Request.new(Safecharge::Constants::SERVER_TEST, full_params)
      req.should_not eq nil
      req.full_url.should_not eq req.url
    end

    it "should create a request when called from the top with minimal params" do
      url = Safecharge.request_url(params)
      url.should_not eq nil
    end

    it "should create a request when called from the top with all params" do
      url = Safecharge.request_url(full_params)
      url.should_not eq nil
    end
  end
  
  describe "negative tests" do
    it "should fail create a request when called from the top with bad mode" do
      expect {Safecharge.request_url(params, 'yeehaaa')}.to raise_error ArgumentError
    end

    it "should fail to create a request with a bad url" do
      expect {Safecharge::Request.new('bad_url')}.to raise_error ArgumentError
    end

    it "should fail to create a request with bad input" do
      new_params = { }
  		expect {Safecharge::Request.new(Safecharge::Constants::SERVER_TEST, new_params)}.to raise_error Safecharge::ValidationException
      new_params.merge!({'merchant_id' => 4797923801005868286})
  		expect {Safecharge::Request.new(Safecharge::Constants::SERVER_TEST, new_params)}.to raise_error Safecharge::ValidationException
      new_params.merge!({'merchant_site_id' => 37501})
    
      expect {Safecharge::Request.new(Safecharge::Constants::SERVER_TEST, new_params)}.to raise_error Safecharge::ValidationException
      new_params.merge!({'first_name' => 'John'})
      expect {Safecharge::Request.new(Safecharge::Constants::SERVER_TEST, new_params)}.to raise_error Safecharge::ValidationException
      new_params.merge!({'last_name' => 'Citizen'})
      expect {Safecharge::Request.new(Safecharge::Constants::SERVER_TEST, new_params)}.to raise_error Safecharge::ValidationException
      new_params.merge!({'city' => 'New York'})
  		expect {Safecharge::Request.new(Safecharge::Constants::SERVER_TEST, new_params)}.to raise_error Safecharge::ValidationException
      new_params.merge!({'country' => 'USA'})
				
  		expect {Safecharge::Request.new(Safecharge::Constants::SERVER_TEST, new_params)}.to raise_error Safecharge::ValidationException
      new_params.merge!({'total_amount' => 15})
  		expect {Safecharge::Request.new(Safecharge::Constants::SERVER_TEST, new_params)}.to raise_error Safecharge::ValidationException
      item = {'name' => 'ball'}
      new_params.merge!({'items' => [item]})
  		expect {Safecharge::Request.new(Safecharge::Constants::SERVER_TEST, new_params)}.to raise_error Safecharge::ValidationException
      item.merge!({'number' => 'sku12345'})
      new_params.merge!({'items' => [item]})
  		expect {Safecharge::Request.new(Safecharge::Constants::SERVER_TEST, new_params)}.to raise_error Safecharge::ValidationException
      item.merge!({'amount' => "ten"})
      new_params.merge!({'items' => [item]})
  		expect {Safecharge::Request.new(Safecharge::Constants::SERVER_TEST, new_params)}.to raise_error Safecharge::ValidationException
      item.merge!({'amount' => 15})
      new_params.merge!({'items' => [item]})
  		expect {Safecharge::Request.new(Safecharge::Constants::SERVER_TEST, new_params)}.to raise_error Safecharge::ValidationException
      item.merge!({'quantity' => 1})
      new_params.merge!({'items' => [item]})
  		expect {Safecharge::Request.new(Safecharge::Constants::SERVER_TEST, new_params)}.to_not raise_error

      new_params.merge!({'nonsense' => 'not here please'})
  		expect {Safecharge::Request.new(Safecharge::Constants::SERVER_TEST, new_params)}.to raise_error Safecharge::InternalException
    
      item.merge!({'unknown' => "whatsallthisthen?"})
      new_params.merge!({'items' => [item]})
  		expect {Safecharge::Request.new(Safecharge::Constants::SERVER_TEST, new_params)}.to raise_error Safecharge::InternalException
    end
  end
end
