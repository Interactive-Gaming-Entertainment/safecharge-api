#!/user/bin/env ruby
#coding: utf-8

require "safecharge/version"
require "safecharge/constants"

describe Safecharge do
  it "should be version 0.0.1" do
    Safecharge::VERSION.should eq "0.0.1"
  end

  it "should have constants" do
    Safecharge::Constants::API_VERSION.should eq '3.0.0'
    Safecharge::Constants::SERVER_LIVE.should eq 'https://secure.safecharge.com/ppp/purchase.do?'
	  Safecharge::Constants::SERVER_TEST.should eq 'https://ppp-test.safecharge.com/ppp/purchase.do?'

    Safecharge::Constants::DEFAULT_ENCODING.should eq 'utf-8'
    Safecharge::Constants::DEFAULT_CURRENCY_CODE.should eq 'USD'

  end

end
