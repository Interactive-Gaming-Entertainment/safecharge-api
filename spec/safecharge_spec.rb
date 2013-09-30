#!/user/bin/env ruby
#coding: utf-8

require "safecharge/version"
require "safecharge/constants"
require 'spec_helper'

describe Safecharge do
  it "should be version 0.0.5" do
    Safecharge::VERSION.should eq "0.0.5"
  end

  it "should have constants" do
    Safecharge::Constants::API_VERSION.should eq '3.0.0'
    Safecharge::Constants::DEFAULT_ENCODING.should eq 'utf-8'
    Safecharge::Constants::DEFAULT_CURRENCY_CODE.should eq 'EUR'
  end

  it "should have loaded environment variables" do
    Safecharge::Constants::SERVER_LIVE.should_not be_nil
    Safecharge::Constants::SERVER_LIVE.should_not be_empty
	  Safecharge::Constants::SERVER_TEST.should_not be_nil
	  Safecharge::Constants::SERVER_TEST.should_not be_empty

    Safecharge::Constants::SECRET_KEY.should_not be_nil
    Safecharge::Constants::SECRET_KEY.should_not be_empty
    Safecharge::Constants::MERCHANT_ID.should_not be_nil
    Safecharge::Constants::MERCHANT_ID.should_not eq 0
    Safecharge::Constants::MERCHANT_SITE_ID.should_not be_nil
    Safecharge::Constants::MERCHANT_SITE_ID.should_not eq 0
    Safecharge::Constants::MERCHANT_3D_SITE_ID.should_not be_nil
    Safecharge::Constants::MERCHANT_3D_SITE_ID.should_not eq 0
    
    Safecharge::Constants::SG_CLIENT_PASSWORD.should_not be_nil
    Safecharge::Constants::SG_CLIENT_PASSWORD.should_not be_empty
    Safecharge::Constants::SG_3D_CLIENT_PASSWORD.should_not be_nil
    Safecharge::Constants::SG_3D_CLIENT_PASSWORD.should_not be_empty
    
    Safecharge::Constants::CPANEL_PASSWORD.should_not be_nil
    Safecharge::Constants::CPANEL_PASSWORD.should_not be_empty
  end
end
