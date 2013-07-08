#!/user/bin/env ruby
#coding: utf-8

require "safecharge"
require "safecharge/constants"
require 'net/http'

module Safecharge
  class Request
    attr_accessor :id, :settings, :params, :url_raw, :url, :response
    
    TRANSACTION_FIELDS = [
      # Customer Details
      { :name => 'sg_FirstName',      :type => 'string',  :size => 30,  :required => true},
      { :name => 'sg_LastName',       :type => 'string',  :size => 40,  :required => true},
      { :name => 'sg_Address',        :type => 'string',  :size => 60,  :required => true},
      { :name => 'sg_City',           :type => 'string',  :size => 30,  :required => true},
      { :name => 'sg_State',          :type => 'string',  :size => 30,  :required => true},
      { :name => 'sg_Zip',            :type => 'string',  :size => 10,  :required => true},
      { :name => 'sg_Country',        :type => 'string',  :size => 3,   :required => true},
      { :name => 'sg_Phone',          :type => 'string',  :size => 18,  :required => true},
      { :name => 'sg_IPAddress',      :type => 'string',  :size => 15,  :required => true},
      { :name => 'sg_Email',          :type => 'string',  :size => 100, :required => true},
      { :name => 'sg_Ship_Country',   :type => 'string',  :size => 2,   :required => false},
      { :name => 'sg_Ship_State',     :type => 'string',  :size => 2,   :required => false},
      { :name => 'sg_Ship_City',      :type => 'string',  :size => 30,  :required => false},
      { :name => 'sg_Ship_Address',   :type => 'string',  :size => 60,  :required => false},
      { :name => 'sg_Ship_Zip',       :type => 'string',  :size => 10,  :required => false},
      # Transaction Details
      { :name => 'sg_Is3dTrans',      :type => 'numeric', :size => 1,   :required => true},
      { :name => 'sg_TransType',      :type => 'string',  :size => 20,  :required => true},
      { :name => 'sg_Currency',       :type => 'string',  :size => 3,   :required => true},
      { :name => 'sg_Amount',         :type => 'string',  :size => 10,  :required => true},
      { :name => 'sg_AuthCode',       :type => 'string',  :size => 10,  :required => 
                                      [Safecharge::Constants::REQUEST_TYPE_SETTLE,
                                       Safecharge::Constants::REQUEST_TYPE_CREDIT,
                                       Safecharge::Constants::REQUEST_TYPE_VOID]},
      { :name => 'sg_ClientLoginID',  :type => 'string',  :size => 24,  :required => true},
      { :name => 'sg_ClientPassword', :type => 'string',  :size => 24,  :required => true},
      { :name => 'sg_ClientUniqueID', :type => 'string',  :size => 64,  :required => false},
      { :name => 'sg_TransactionID',  :type => 'int',     :size => 32,  :required => 
                                      [Safecharge::Constants::REQUEST_TYPE_SETTLE,
                                       Safecharge::Constants::REQUEST_TYPE_CREDIT,
                                       Safecharge::Constants::REQUEST_TYPE_VOID]},
      { :name => 'sg_AVS_Approves',   :type => 'string',  :size => 10,  :required => false},
      { :name => 'sg_CustomData',     :type => 'string',  :size => 255, :required => false},
      { :name => 'sg_UserID',         :type => 'string',  :size => 50,  :required => false},
      { :name => 'sg_CreditType',     :type => 'int',     :size => 1,   :required => 
                                      [Safecharge::Constants::REQUEST_TYPE_CREDIT]},
      { :name => 'sg_WebSite',        :type => 'string',  :size => 50,  :required => false},
      { :name => 'sg_ProductID',      :type => 'string',  :size => 50,  :required => false},
      { :name => 'sg_ResponseFormat', :type => 'numeric', :size => 1,   :required => true},
      { :name => 'sg_Rebill',         :type => 'string',  :size => 10,  :required => false},
      { :name => 'sg_ResponseURL',    :type => 'string',  :size => 256, :required => false},
      { :name => 'sg_TemplateID',     :type => 'string',  :size => 10,  :required => false},
      { :name => 'sg_VIPCardHolder',  :type => 'int',     :size => 1,   :required => false},
      # Credit / Debit Card Details
      { :name => 'sg_NameOnCard',     :type => 'string',  :size => 70,  :required => true},
      { :name => 'sg_CardNumber',     :type => 'string',  :size => 20,  :required => true},
      { :name => 'sg_ExpMonth',       :type => 'string',  :size => 2,   :required => true},
      { :name => 'sg_ExpYear',        :type => 'string',  :size => 2,   :required => true},
      { :name => 'sg_CVV2',           :type => 'numeric', :size => 4,   :required => true},
      { :name => 'sg_DC_Issue',       :type => 'numeric', :size => 2,   :required => false},
      { :name => 'sg_DC_StartMon',    :type => 'string',  :size => 2,   :required => false},
      { :name => 'sg_DC_StartYear',   :type => 'string',  :size => 2,   :required => false},
      { :name => 'sg_IssuingBankName',:type => 'string',  :size => 255, :required => false}
    ]
    
    TRANSACTION_TYPES = [
      Safecharge::Constants::REQUEST_TYPE_AUTH,
      Safecharge::Constants::REQUEST_TYPE_SETTLE,
      Safecharge::Constants::REQUEST_TYPE_SALE,
      Safecharge::Constants::REQUEST_TYPE_CREDIT,
      Safecharge::Constants::REQUEST_TYPE_VOID,
      Safecharge::Constants::REQUEST_TYPE_AVS
    ]
    
    def initialize(settings = {}, id = nil)
      self.settings = Safecharge::DEFAULT_SETTINGS.merge(settings)
      self.id = (id) ? id : generate_id
      self.params = default_params
    end
    
    def set_type(type)
      self.validate_type(type)
      self.params['sg_TransType'] = type
    end
    
    def validate_type(type)
      raise ArgumentException, "Transaction type required, but not specified" if type.is_empty?
      raise ArgumentException, "Transaction type '#{type}' is not supported" unless TRANSACTION_TYPES.includes?(type)
    end

    def send
      uri = URI(self.url_raw)
      uri.query = URI.encode_www_form(self.params)
      self.response = Net::HTTP.get(uri)
      return self
    end

    def clean_card_number(number)
      result = number.gsub(/\D/, '')
      return result
    end

    def validate_no_extra_fields(params)
      allowed_fields = []
      self.TRANSACTION_FIELDS.each {|field| allowed_fields << field['name'] }
      params.each do |key, value|
        raise InternalException, "Field #{key} is not supported" if !allowed_fields.includes?(key)
      end
    end

    def validate_card_number(params)
      card_number = params['sg_CardNumber']
      card_number = self.clean_card_number(card_number)
      card_length = card_number.size
      
      raise CardNumberException, "Card number is too short" if cardLength < SafechargeConstants::CARD_NUMBER_MIN_LENGTH
      raise CardNumberException, "Card number is too long" if cardLength > SafechargeConstants::CARD_NUMBER_MAX_LENGTH

      parity = card_length % 2
      sum = 0;
      for i in  0..card_length
        digit = card_number[i]
        digit = digit * 2 if i % 2 == parity
        digit = digit - 9 if digit > 9
        sum = sum + digit
      end
      valid = (sum % 10 == 0) ? true : false; 
      raise CardNumberException, "Invalid checksum" unless valid

    end
    protected

    def generate_id
      return "[QUERY #{(1..100000).to_a.sample}]"
    end

    def default_params
      return {
        'sg_ClientLoginID'  => self.settings['username'],
        'sg_ClientPassword' => self.settings['password'],
        'sg_IPAddress'      => Safecharge::Constants::REQUEST_DEFAULT_IP_ADDRESS,
        'sg_ResponseFormat' => Safecharge::Constants::REQUEST_DEFAULT_RESPONSE_FORMAT,
        'sg_Is3dTrans'      => Safecharge::Constants::REQUEST_DEFAULT_IS_3D_TRANS,
        'sg_ClientUniqueID' => Time.now.to_s
      }
    end

    def build(safe = false)
      result = ''

      params = self.params
      if safe
        # Replace completely
        if !params['sg_ClientPassword'].empty?
          params['sg_ClientPassword'] = self.pad_string(params['sg_ClientPassword'], 0, 0, 'x')
        end
        if !params['sg_CVV2'].empty?
          params['sg_CVV2'] = self.padString(params['sg_CVV2'], 0, 0, 'x')
        end

        # Replace partially
        if !params['sg_CardNumber'].empty?
          params['sg_CardNumber'] = self.pad_string(params['sg_CardNumber'], 6, 4, 'x')
        end
      end
      server = self.settings['live'] ? Safecharge::Constants::SERVER_LIVE : Safecharge::Constants::SERVER_TEST
      result = "#{server}#{http_build_query(params)}"

      return result;
    end


    def pad_string(string, start_count = nil, end_count =nil, character = nil)
      result = ''
      start_count = self.settings['padFrom'] if start_count == nil
      end_count = self.settings['padTo'] if end_count == nil
      character = self.settings['padWith'] if character == nil
      length = string.size - start_count - end_count
      if length <= 0
        result = string
      else
        replacement = sprintf("%#{character}#{length}s", character)
        result = string[0..start_count] << replacement << string[end_count]
      end
      return result
    end

  end
end
