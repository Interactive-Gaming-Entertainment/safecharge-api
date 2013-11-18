#!/user/bin/env ruby
#coding: utf-8

require "safecharge"
require "safecharge/dmn"
require 'spec_helper'

describe Safecharge::DMN do

  it "should comopute the correct checksum" do
    # data from page 4 / 5 of Direct Merchant Notification_vv3j1.pdf
    sample_data = {
      'key' => 'AJHFH9349JASFJHADJ9834',
      'totalAmount' => 115,
      'currency' => 'USD',
      'responseTimeStamp' => '2007-11-13.13:22:34',
      'PPP_TransactionID' => 3453459,
      'Status' => 'APPROVED',
      'productId' => 'YourProduct'
    }
    Safecharge::DMN.checksum(sample_data).should eq '826fb8c4a2451e86f41df511c46f5a9b'
  end
end
