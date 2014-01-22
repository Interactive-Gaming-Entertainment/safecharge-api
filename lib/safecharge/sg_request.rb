#!/user/bin/env ruby
#coding: utf-8

require "safecharge"
require "safecharge/constants"

module Safecharge
  class SgRequest < Request

    ALLOWED_FIELDS = {
      'sg_NameOnCard' => {:required => true, :type => 'string', length: 70},
      'sg_CardNumber' => {:required => true, :type => 'string', length: 20},
      'sg_ExpMonth' => {:required => true, :type => 'string', length: 2},
      'sg_ExpYear' => {:required => true, :type => 'string', length: 2},
      'sg_TransType' => {:required => true, :type => 'sgtranstype'},
      'sg_Currency' => {:required => true, :type => 'currency_code'},
      'sg_Amount' => {:required => true, :type => 'currency'},
      'sg_AuthCode' => {:required => false, :type => 'string', length: 10},
      'sg_ClientLoginID' => {:required => true, :type => 'string', length: 24},
      'sg_ClientPassword' => {:required => true, :type => 'string', length: 24},
      'sg_ClientUniqueID' => {:required => false, :type => 'string', length: 64},
      'sg_TransactionID' => {:required => false, :type => 'string', length: 32},
      'sg_CreditType' => {:required => true, :type => 'int'},
      'sg_ResponseFormat' => {:required => true, :type => 'int'},
      'sg_Version' => {:required => false, :type => 'string', length: 5},
      'sg_FirstName' => {:required => true, :type => 'string', length: 30},
      'sg_LastName' => {:required => true, :type => 'string', length: 40},
      'sg_Address' => {:required => true, :type => 'string', length: 60},
      'sg_City' => {:required => true, :type => 'string', length: 30},
      'sg_State' => {:required => false, :type => 'string', length: 30},
      'sg_Zip' => {:required => true, :type => 'string', length: 10}, # post code
      'sg_Country' => {:required => true, :type => 'string', length: 3}, # ISO Code
      'sg_Phone' => {:required => true, :type => 'string', length: 18},
      'sg_IPAddress' => {:required => true, :type => 'string', length: 15},
      'sg_Email' => {:required => true, :type => 'string', length: 100}

    }

    DEFAULT_PARAMS = {
      'sg_ClientLoginID' => Safecharge::Constants::SG_CLIENT_LOGIN_ID,
      'sg_ClientPassword' => Safecharge::Constants::SG_CLIENT_PASSWORD,
      'sg_Currency' => Safecharge::Constants::DEFAULT_CURRENCY_CODE,
      'sg_CreditType' => Safecharge::Constants::SG_DEFAULT_CREDIT_TYPE,
      'sg_Version' => Safecharge::Constants::SG_API_VERSION,
      'sg_ResponseFormat' => Safecharge::Constants::SG_RESPONSE_FORMAT
    }

    def initialize(a_url, some_params = {})
      raise ArgumentError, "missing url" if a_url == nil || a_url.empty?
      if a_url === Safecharge::Constants::SG_SERVER_TEST
        self.mode = 'test'
      elsif a_url === Safecharge::Constants::SG_SERVER_LIVE
        self.mode = 'live'
      else
        raise ArgumentError, "invalid url #{a_url}"
      end
      self.url = a_url
      self.full_url = a_url
      self.params = DEFAULT_PARAMS.merge(convert_symbols_to_strings(some_params))
      self.validate_parameters(self.params)
      self.construct_url
    end

  end
end
