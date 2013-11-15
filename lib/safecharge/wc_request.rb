#!/user/bin/env ruby
#coding: utf-8

require "safecharge"
require "safecharge/constants"

module Safecharge
  class WcRequest < Request

    ALLOWED_FIELDS = {
      'currency' => {:required => true, :type => 'currency_code'},
      'customData' => {:required => false, :type => 'string', length: 255},
      'customSiteName' => {:required => false, :type => 'string', length: 50},
      'discount' => {:required => false, :type => 'currency'},
      'encoding' => {:required => false, :type => 'string', length: 20},
      'error_url' => {:required => false, :type => 'string', length: 300},
      'handling' => {:required => false, :type => 'currency'},
      'invoice_id' =>  {:required => false, :type => 'string', length: 400},
      'merchant_id' => {:required => true, :type => 'int'},
      'merchant_site_id' => {:required => true, :type => 'int'},
      'merchant_unique_id' => {:required => false, :type => 'string', length: 64},
      'merchantLocale' => {:required => false, :type => 'string', length: 5},
      'payment_method' => {:required => false, :type => 'string', length: 256},
      'pending_url' => {:required => false, :type => 'string', length: 300},
      'productId' => {:required => false, :type => 'string', length: 50},
      'shipping' => {:required => false, :type => 'currency'},
      'skip_billing_tab' => {:required => false, :type => 'boolstring'},
      'skip_review_tab' => {:required => false, :type => 'boolstring'},
      'success_url' => {:required => false, :type => 'string', length: 300},
      'total_amount' => {:required => true, :type => 'currency'},
      'total_tax' => {:required => false, :type => 'percent'},
      'userid' => {:required => false, :type => 'string', length: 50},
      'version' => {:required => true, :type => 'string', length: 10},
      'webMasterId' => {:required => false, :type => 'string', length: 255},
      'user_token' => {:required => false, :type => 'usertoken'},
      'user_token_id' => {:required => true, :type => 'string', length: 45},
      'first_name' => {:required => false, :type => 'string', length: 30},
      'last_name' => {:required => false, :type => 'string', length: 40},
      'city' => {:required => false, :type => 'string', length: 30},
      'country' => {:required => false, :type => 'string', length: 20},
      'state' => {:required => false, :type => 'string', length: 20}, # ISO code
      'zip' => {:required => false, :type => 'string', length: 10}, # post code
      'address1' => {:required => false, :type => 'string', length: 60},
      'address2' => {:required => false, :type => 'string', length: 60}

    } # 'time_stamp', 'numberofitems' and 'checksum' are inserted after validation.

    ALLOWED_ITEM_FIELDS = {
      'name' => {:required => true, :type => 'string', length: 400},
      'number' => {:required => true, :type => 'string', length: 400},
      'amount' => {:required => true, :type => 'currency'},
      'quantity' => {:required => true, :type => 'int'},
      'discount' => {:required => false, :type => 'percent'},
      'shipping' => {:required => false, :type => 'currency'},
      'handling' => {:required => false, :type => 'currency'},
      'open_amount' => {:required => false, :type => 'boolstring'},
      'min_amount' => {:required => false, :type => 'currency'},
      'max_amount' => {:required => false, :type => 'currency'}
    }

    def initialize(url, params = {})
      super(url, params)
    end

    protected

    def calculate_checksum
      codes = [Safecharge::Constants::SECRET_KEY,
              self.params['merchant_id'],
              self.params['currency'],
              self.params['total_amount']]
      self.items.each do |item|
        codes << item['name']
        codes << item['amount']
        codes << item['quantity']
        codes << item['open_amount']
        codes << item['min_amount']
        codes << item['max_amount']
      end
      codes << self.params['user_token_id']
      codes << self.params['time_stamp']
      s = codes.join('')
      return Digest::MD5.hexdigest(s)
    end

  end
end
