#!/user/bin/env ruby
#coding: utf-8

require "safecharge"
require "safecharge/constants"

module Safecharge
  class Response

    def self.code(err, exerr = 0)
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

    def self.checksum(opts = {})
      params = {
        'key' => Safecharge::Constants::SECRET_KEY
      }.merge(opts)
      codes = [params['key'],
              params['totalAmount'],
              params['currency'],
              params['responseTimeStamp'],
              params['PPP_TransactionID'],
              params['Status'],
              params['productId']]
      s = codes.join('')
      return Digest::MD5.hexdigest(s)
    end
  end
end
