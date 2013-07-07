#!/user/bin/env ruby
#coding: utf-8

require "safecharge/version"
require "safecharge/constants"

describe Safecharge do
  it "should be version 0.0.1" do
    Safecharge::VERSION.should eq "0.0.1"
  end

  it "should have constants" do
    Safecharge::Constants::SERVER_LIVE.should eq 'https://process.safecharge.com/service.asmx/Process?'
	  Safecharge::Constants::SERVER_TEST.should eq 'https://test.safecharge.com/service.asmx/Process?'

	  Safecharge::Constants::REQUEST_TYPE_AUTH.should eq 'Auth'
	  Safecharge::Constants::REQUEST_TYPE_SETTLE.should eq 'Settle'
	  Safecharge::Constants::REQUEST_TYPE_SALE.should eq 'Sale'
	  Safecharge::Constants::REQUEST_TYPE_CREDIT.should eq'Credit'
	  Safecharge::Constants::REQUEST_TYPE_VOID.should eq 'Void'
	  Safecharge::Constants::REQUEST_TYPE_AVS.should eq 'AVSOnly'

	  Safecharge::Constants::REQUEST_DEFAULT_USERNAME.should eq ''
	  Safecharge::Constants::REQUEST_DEFAULT_PASSWORD.should eq ''
	  Safecharge::Constants::REQUEST_DEFAULT_TIMEOUT.should eq 30
	  Safecharge::Constants::REQUEST_DEFAULT_LIVE.should eq false

	  Safecharge::Constants::REQUEST_DEFAULT_IP_ADDRESS.should eq '127.0.0.1'
	  Safecharge::Constants::REQUEST_DEFAULT_RESPONSE_FORMAT.should eq 4
	  Safecharge::Constants::REQUEST_DEFAULT_IS_3D_TRANS.should eq 0

	  Safecharge::Constants::RESPONSE_STATUS_APPROVED.should eq 'APPROVED'
	  Safecharge::Constants::RESPONSE_STATUS_SUCCESS.should eq 'SUCCESS'
	  Safecharge::Constants::RESPONSE_STATUS_DECLINED.should eq 'DECLINED'
	  Safecharge::Constants::RESPONSE_STATUS_ERROR.should eq 'ERROR'
	  Safecharge::Constants::RESPONSE_STATUS_PENDING.should eq 'PENDING'

	  Safecharge::Constants::RESPONSE_XML_VERSION.should eq '1.0'
	  Safecharge::Constants::RESPONSE_XML_ENCODING.should eq 'utf-8'

	  Safecharge::Constants::DEFAULT_PAD_FROM.should eq 6
	  Safecharge::Constants::DEFAULT_PAD_TO.should eq 4
	  Safecharge::Constants::DEFAULT_PAD_WITH.should eq  'x'

	  Safecharge::Constants::CARD_NUMBER_MIN_LENGTH.should eq 13
	  Safecharge::Constants::CARD_NUMBER_MAX_LENGTH.should eq 19

  end

end
