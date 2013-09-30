#!/user/bin/env ruby
#coding: utf-8

require "safecharge"
require "safecharge/constants"

module Safecharge
  class Response
    attr_accessor :params

    ALLOWED_FIELDS = [
      'Status', 'totalAmount', 'TransactionID', 'ClientUniqueID', 'ErrCode',
      'ExErrCode', 'AuthCode', 'Reason', 'Token', 'ReasonCode',
      'advanceResponseChecksum', 'ECI',
      'nameOnCard', 'currency', 
      'total_discount', 'total_handling', 'total_shipping', 'total_tax',
      'customData', 'merchant_unique_id', 'merchant_site_id',
      'requestVersion', 'message', 'Error', 'PPP_TransactionID', 'UserID',
      'ProductID', 'ppp_status', 'merchantLocale', 'unknownParameters', 'webMasterId'
    ]

    def initialize(incoming_encoded_params = nil)
      self.params = self.decode(incoming_encoded_params)
    end

    def decode(param_string)
      #TODO: write this.
      return {}
    end

    def self.code(err, exerr)
      return Safecharge::Constants::APPROVED if err == 0 && exerr == 0
      return Safecharge::Constants::DECLINED if err == -1 && exerr == 0
      # pending? see p 22 of the spec
      return Safecharge::Constants::ERROR if err == -1100 && exerr > 0
      # could be more specific. see p 22 of the spec for exerr codes
      return Safecharge::Constants::BANK_ERROR if err < 0 && exerr != 0
      return Safecharge::Constants::INVALID_LOGIN if err == -1001
      return Safecharge::Constants::INVALID_IP if err == -1005
      return Safecharge::Constants::TIMEOUT if err == -1203
      return Safecharge::Constants::UNKNOWN_ERROR
    end

    protected

    def calculate_checksum
      codes = [Safecharge::Constants::SECRET_KEY,
              self.params['totalAmount'],
              self.params['currency'],
              self.params['responseTimeStamp'],
              self.params['PPP_TransactionID'],
              self.params['Status'],
              self.params['productId']]
      s = codes.join('')
      return Digest::MD5.hexdigest(s)
    end
  end
end
