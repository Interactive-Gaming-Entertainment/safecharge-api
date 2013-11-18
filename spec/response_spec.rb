#!/user/bin/env ruby
#coding: utf-8

require "safecharge"
require "safecharge/constants"
require "safecharge/response"
require 'spec_helper'

describe Safecharge::Response do

  it "should return the correct error code" do
    Safecharge::Response.code(0,0).should eq Safecharge::Constants::APPROVED
    Safecharge::Response.code(-1,0).should eq Safecharge::Constants::DECLINED
    # Safecharge::Response.code(0,0).should eq Safecharge::Constants::PENDING
    Safecharge::Response.code(-1100,1).should eq Safecharge::Constants::ERROR
    Safecharge::Response.code(-1,1).should eq Safecharge::Constants::BANK_ERROR
    Safecharge::Response.code(-1001,0).should eq Safecharge::Constants::INVALID_LOGIN
    Safecharge::Response.code(-1005,0).should eq Safecharge::Constants::INVALID_IP
    Safecharge::Response.code(-1203,0).should eq Safecharge::Constants::TIMEOUT
    Safecharge::Response.code(1,1).should eq Safecharge::Constants::UNKNOWN_ERROR
  end

end
