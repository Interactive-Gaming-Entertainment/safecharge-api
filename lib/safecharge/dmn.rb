#!/user/bin/env ruby
#coding: utf-8

require "safecharge"
require "safecharge/constants"

module Safecharge
  class DMN
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
