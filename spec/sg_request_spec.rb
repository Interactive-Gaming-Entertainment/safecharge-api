#!/user/bin/env ruby
#coding: utf-8

require "safecharge"
require "safecharge/constants"
require "safecharge/request"
require 'spec_helper'
require 'safecharge/sg_request'

describe Safecharge::SgRequest do

  let(:params) { {
    'sg_NameOnCard' => 'John+Doe',
    'sg_ExpMonth' => '01',
    'sg_ExpYear' => '15',
    'sg_TransType' => 'Credit',
    'sg_Amount' => 112,
    'sg_ClientLoginID' => 'TestLogin',
    'sg_ClientPassword' => 'TestPassword',
    'sg_FirstName' => 'John',
    'sg_LastName' => 'Doe',
    'sg_Address' => 'Street 12',
    'sg_City' => 'Cityville',
    'sg_Zip' => '12345X', # post code
    'sg_Country' => 'GB', # ISO Code
    'sg_Phone' => '5555555',
    'sg_IPAddress' => '123.123.123.123',
    'sg_Email' => 'john.doe@email.com'
  } }

  let(:sym_params) { {
      sg_NameOnCard: 'John+Doe',
      sg_ExpMonth: '01',
      sg_ExpYear: '15',
      sg_TransType: 'Credit',
      sg_Amount: 112.34,
      sg_ClientLoginID: 'TestLogin',
      sg_ClientPassword: 'TestPassword',
      sg_FirstName: 'John',
      sg_LastName: 'Doe',
      sg_Address: 'Street 12',
      sg_City: 'Cityville',
      sg_Zip: '12345X', # post code
      sg_Country: 'GB', # ISO Code
      sg_Phone: '5555555',
      sg_IPAddress: '123.123.123.123',
      sg_Email: 'john.doe@email.com'
  } }

  let(:full_params) {
    params.merge({
        'sg_CardNumber' => '4444444444444444',
        'sg_CCToken' => 'Tokennnnnnnnnnnnnnnnnnnnnnnn',
        'sg_AuthCode' => 'AuthCode01',
        'sg_ClientUniqueID' => 'Txid1234567A',
        'sg_TransactionID' => 'OriginalTxid5678',
        'sg_State' => 'Sunshine State'
    })
  }

  describe "positive tests" do
    it "should create a request with minimal params" do
  		req = Safecharge::SgRequest.new(Safecharge::Constants::SG_SERVER_TEST, params)
      req.should_not eq nil
      req.full_url.should_not eq req.url
    end

    it "should create a request with minimal symbol params" do
  		req = Safecharge::SgRequest.new(Safecharge::Constants::SG_SERVER_TEST, sym_params)
      req.should_not eq nil
      req.full_url.should_not eq req.url
    end

    it "should create a request when called from the top with minimal params" do
      url = Safecharge.sg_request_url(params)
      url.should_not eq nil
    end

    it "should create a request with maxed out params" do
  		req = Safecharge::SgRequest.new(Safecharge::Constants::SG_SERVER_TEST, full_params)
      req.should_not eq nil
      req.full_url.should_not eq req.url
    end

    it "should create a request when called from the top with maxed out params" do
      url = Safecharge.sg_request_url(full_params)
      url.should_not eq nil
    end
  end
  
  describe "negative guests" do
    it "should fail create a request when called from the top with bad mode" do
      expect {Safecharge.sg_request_url(params, 'yeehaaa')}.to raise_error ArgumentError
    end

    it "should fail to create a request with a bad url" do
      expect {Safecharge::SgRequest.new('bad_url')}.to raise_error ArgumentError
    end
  end
end

