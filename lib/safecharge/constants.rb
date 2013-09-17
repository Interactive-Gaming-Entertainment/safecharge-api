#!/user/bin/env ruby
#coding: utf-8

module Safecharge
  class Constants
    API_VERSION = '3.0.0'

    SERVER_TEST = ENV['SAFECHARGE_SERVER_TEST']                     # provided by SafeCharge
    SERVER_LIVE = ENV['SAFECHARGE_SERVER_LIVE']                     # provided by SafeCharge
    
    SECRET_KEY = ENV['SAFECHARGE_SECRET_KEY']                       # provided by SafeCharge
    MERCHANT_ID =  ENV['SAFECHARGE_MERCHANT_ID']                    # provided by SafeCharge
    MERCHANT_SITE_ID = ENV['SAFECHARGE_MERCHANT_SITE_ID']           # provided by SafeCharge
    MERCHANT_3D_SITE_ID = ENV['SAFECHARGE_MERCHANT_3D_SITE_ID']     # provided by SafeCharge
    
    SG_CLIENT_PASSWORD = ENV['SAFECHARGE_SG_CLIENT_PASSWORD']       # provided by SafeCharge
    SG_3D_CLIENT_PASSWORD = ENV['SAFECHARGE_SG_3D_CLIENT_PASSWORD'] # provided by SafeCharge
    
    CPANEL_PASSWORD = ENV['SAFECHARGE_CPANEL_PASSWORD']             # provided by SafeCharge

    APPROVED = 'APPROVED'
    DECLINED = 'DECLINED'
    ERROR = 'ERROR'
    BANK_ERROR = 'BANK_ERROR'
    INVALID_LOGIN = 'INVALID_LOGIN'
    INVALID_IP = 'INVALID_IP'
    TIMEOUT = 'TIMEOUT'
    UNKNOWN_ERROR = 'UNKNOWN_ERROR'

    CURRENCIES = [
      'GBP', 'EUR', 'USD', 'HKD', 'YEN', 'AUD', 'CAD',
      'NOK', 'ZAR', 'SEK', 'CHF', 'NIS', 'MXN', 'RUB'
    ]
#     REQUEST_TYPE_AUTH   = 'Auth'
#     REQUEST_TYPE_SETTLE = 'Settle'
#     REQUEST_TYPE_SALE   = 'Sale'
#     REQUEST_TYPE_CREDIT = 'Credit'
#     REQUEST_TYPE_VOID   = 'Void'
#     REQUEST_TYPE_AVS    = 'AVSOnly'

    DEFAULT_ENCODING = 'utf-8'
    DEFAULT_CURRENCY_CODE = 'EUR'
  end
end
