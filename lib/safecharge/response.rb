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

  end
end
