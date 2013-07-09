#!/user/bin/env ruby
#coding: utf-8

module Safecharge
  class Constants
    API_VERSION = '3.0.0'

    SERVER_TEST = 'https://ppp-test.safecharge.com/ppp/purchase.do?'
    SERVER_LIVE = 'https://secure.safecharge.com/ppp/purchase.do?'
    
    SECRET_KEY = ENV['SAFECHARGE_SECRET_KEY'] || 'you must set this'
    MERCHANT_ID =  ENV['SAFECHARGE_MERCHANT_ID'] || 'you must set this'
    MERCHANT_SITE_ID = ENV['SAFECHARGE_MERCHANT_SITE_ID'] || 'you must set this'

#     REQUEST_TYPE_AUTH   = 'Auth'
#     REQUEST_TYPE_SETTLE = 'Settle'
#     REQUEST_TYPE_SALE   = 'Sale'
#     REQUEST_TYPE_CREDIT = 'Credit'
#     REQUEST_TYPE_VOID   = 'Void'
#     REQUEST_TYPE_AVS    = 'AVSOnly'
# 
#     RESPONSE_STATUS_APPROVED = 'APPROVED'
#     RESPONSE_STATUS_SUCCESS  = 'SUCCESS'
#     RESPONSE_STATUS_DECLINED = 'DECLINED'
#     RESPONSE_STATUS_ERROR    = 'ERROR'
#     RESPONSE_STATUS_PENDING  = 'PENDING'

    DEFAULT_ENCODING = 'utf-8'
    DEFAULT_CURRENCY_CODE = 'USD'
  end
end
