#!/user/bin/env ruby
#coding: utf-8

# see also http://ruby-doc.org/stdlib-2.0.0/libdoc/net/http/rdoc/Net/HTTP.html

require "safecharge"
require "safecharge/constants"
require "safecharge/request"
require 'spec_helper'

require 'net/http'

describe "Safecharge::WcRequest Live Test" do

  let(:params) { { 
    'total_amount' => 25,
    'currency' => 'USD',
    'items' => [
      { 'name' => 'ball',
        'number' => 'sku12345',
        'amount' => 25,
        'quantity' => 1} ]
  } }

  let(:wc_params) { {
    'total_amount' => 150,
    'currency' => 'USD',
    'items' => [
      { 'name' => 'ball',
        'number' => 'sku12345',
        'amount' => 150,
        'quantity' => 1,
        'open_amount' => 'true',
        'min_amount' => 100,
        'max_amount' => 200} ],
    'user_token_id' => 'yayfortokens'
  } }

  it "should respond nicely to a correctly formed request" do
    urlstring = Safecharge.request_url(params)
    urlstring.should_not eq nil
    uri = URI(urlstring)
    response = Net::HTTP.get(uri)
    response.should_not match 'ppp_status=FAIL'
  end

  it "should respond nicely to a correctly formed wc_request" do
    urlstring = Safecharge.wc_request_url(wc_params)
    urlstring.should_not eq nil
    uri = URI(urlstring)
    response = Net::HTTP.get(uri)
    response.should_not match 'ppp_status=FAIL'
  end

end
