#!/user/bin/env ruby
#coding: utf-8

require "safecharge"
require "safecharge/constants"
require 'net/http'

module Safecharge
  class Request
    attr_accessor :id, :settings, :params, :url_raw, :url, :response

    TRANSACTION_FIELDS = {
      # Customer Details
      'sg_FirstName' => { :name => 'sg_FirstName', :type => 'string', :size => 30, :required => true},
      'sg_LastName' => { :name => 'sg_LastName', :type => 'string', :size => 40, :required => true},
      'sg_Address' => { :name => 'sg_Address', :type => 'string', :size => 60, :required => true},
      'sg_City' => { :name => 'sg_City', :type => 'string', :size => 30, :required => true},
      'sg_State' => { :name => 'sg_State', :type => 'string',  :size => 30,  :required => true},
      'sg_Zip' => { :name => 'sg_Zip', :type => 'string',  :size => 10,  :required => true},
      'sg_Country' => { :name => 'sg_Country', :type => 'string',  :size => 3,   :required => true},
      'sg_Phone' => { :name => 'sg_Phone', :type => 'string',  :size => 18,  :required => true},
      'sg_IPAddress' => { :name => 'sg_IPAddress', :type => 'string',  :size => 15,  :required => true},
      'sg_Email' => { :name => 'sg_Email', :type => 'string',  :size => 100, :required => true},
      'sg_Ship_Country' => { :name => 'sg_Ship_Country', :type => 'string',  :size => 2, :required => false},
      'sg_Ship_State' => { :name => 'sg_Ship_State', :type => 'string',  :size => 2, :required => false},
      'sg_Ship_City' => { :name => 'sg_Ship_City', :type => 'string',  :size => 30, :required => false},
      'sg_Ship_Address' => { :name => 'sg_Ship_Address', :type => 'string',  :size => 60, :required => false},
      'sg_Ship_Zip' => { :name => 'sg_Ship_Zip', :type => 'string',  :size => 10, :required => false},
      # Transaction Details
      'sg_Is3dTrans' => { :name => 'sg_Is3dTrans', :type => 'numeric', :size => 1, :required => true},
      'sg_TransType' => { :name => 'sg_TransType', :type => 'string', :size => 20, :required => true},
      'sg_Currency' => { :name => 'sg_Currency', :type => 'string', :size => 3, :required => true},
      'sg_Amount' => { :name => 'sg_Amount', :type => 'string', :size => 10, :required => true},
      'sg_AuthCode' => { :name => 'sg_AuthCode', :type => 'string', :size => 10, :required => 
                                      [Safecharge::Constants::REQUEST_TYPE_SETTLE,
                                       Safecharge::Constants::REQUEST_TYPE_CREDIT,
                                       Safecharge::Constants::REQUEST_TYPE_VOID]},
      'sg_ClientLoginID' => { :name => 'sg_ClientLoginID',  :type => 'string', :size => 24, :required => true},
      'sg_ClientPassword' => { :name => 'sg_ClientPassword', :type => 'string', :size => 24, :required => true},
      'sg_ClientUniqueID' => { :name => 'sg_ClientUniqueID', :type => 'string', :size => 64, :required => false},
      'sg_TransactionID' => { :name => 'sg_TransactionID',  :type => 'int', :size => 32, :required => 
                                      [Safecharge::Constants::REQUEST_TYPE_SETTLE,
                                       Safecharge::Constants::REQUEST_TYPE_CREDIT,
                                       Safecharge::Constants::REQUEST_TYPE_VOID]},
      'sg_AVS_Approves' => { :name => 'sg_AVS_Approves', :type => 'string', :size => 10, :required => false},
      'sg_CustomData' => { :name => 'sg_CustomData', :type => 'string', :size => 255, :required => false},
      'sg_UserID' => { :name => 'sg_UserID', :type => 'string',  :size => 50, :required => false},
      'sg_CreditType' => { :name => 'sg_CreditType', :type => 'int', :size => 1, :required => 
                                      [Safecharge::Constants::REQUEST_TYPE_CREDIT]},
      'sg_WebSite' => { :name => 'sg_WebSite', :type => 'string',  :size =>  50, :required => false},
      'sg_ProductID' => { :name => 'sg_ProductID', :type => 'string',  :size => 50, :required => false},
      'sg_ResponseFormat' => { :name => 'sg_ResponseFormat', :type => 'numeric', :size => 1, :required => true},
      'sg_Rebill' => { :name => 'sg_Rebill', :type => 'string',  :size => 10, :required => false},
      'sg_ResponseURL' => { :name => 'sg_ResponseURL', :type => 'string', :size => 256, :required => false},
      'sg_TemplateID' => { :name => 'sg_TemplateID', :type => 'string', :size => 10, :required => false},
      'sg_VIPCardHolder' => { :name => 'sg_VIPCardHolder',  :type => 'int', :size => 1, :required => false},
      # Credit / Debit Card Details
      'sg_NameOnCard' => { :name => 'sg_NameOnCard', :type => 'string',  :size => 70, :required => true},
      'sg_CardNumber' => { :name => 'sg_CardNumber', :type => 'string',  :size => 20, :required => true},
      'sg_ExpMonth' => { :name => 'sg_ExpMonth', :type => 'string',  :size => 2, :required => true},
      'sg_ExpYear' => { :name => 'sg_ExpYear', :type => 'string',  :size => 2, :required => true},
      'sg_CVV2' => { :name => 'sg_CVV2', :type => 'numeric', :size => 4, :required => true},
      'sg_DC_Issue' => { :name => 'sg_DC_Issue', :type => 'numeric', :size => 2, :required => false},
      'sg_DC_StartMon' => { :name => 'sg_DC_StartMon', :type => 'string', :size => 2, :required => false},
      'sg_DC_StartYear' => { :name => 'sg_DC_StartYear', :type => 'string', :size => 2, :required => false},
      'sg_IssuingBankName' => { :name => 'sg_IssuingBankName',:type => 'string', :size => 255, :required => false}
    }
    
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
    
    def type=(type)
      self.validate_type(type)
      self.params['sg_TransType'] = type
    end
    
    def validate_type(type)
      raise ArgumentException, "Transaction type required, but not specified" if type.empty?
      raise ArgumentException, "Transaction type '#{type}' is not supported" unless TRANSACTION_TYPES.include?(type)
    end

    def send
      uri = URI(self.url_raw)
      uri.query = URI.encode_www_form(self.params)
      self.response = Net::HTTP.get(uri)
      return self
    end

    def clean_card_number(number)
      number = "#{number}" unless number.is_a? String
      result = number.gsub(/\D/, '')
      return result
    end

    def parameters=(params)
      all_params = self.params.merge(params)
      self.validate_parameters(all_params)
      self.params = all_params
      
      # Update request URLs from the new parameters
      self.url_raw = self.build
      self.url = self.build(true)
    end

    def validate_parameters(params)
      self.validate_fields(params)
      self.validate_no_extra_fields(params)
      self.validate_card_number(params)
    end

    def validate_fields(params)
      # puts "params = #{params.inspect}"
      transaction_type = params['sg_TransType']
      # Check for all required fields and formats
      TRANSACTION_FIELDS.each do |name, field|
        # puts "#{name}: #{field[:required]}"
        required = (field[:required] === true) ||
                   (field[:required].is_a?(Array) && field[:required].include?(transaction_type))

        # Check that all required parameters are present
        if required && !params.keys.include?(field[:name])
          raise ValidationException, "Parameter [#{field[:name]}] is required, but not specified in #{params.keys}"
        end
        if params.keys.include? field['name']
          # Check that the format is more or less correct
          if !params[ field[:name]].empty? && params[ field[:name] ].size > field[:size]
            raise ValidationException, sprintf("Value [%s] in field [%s] is over the size limit [%s]", params[ field[:name] ], field[:name], field[:size])
          end

          if !params[ field[:name] ].empty?
            # Check the type of the value
            correct_type = false
            case field[:type]
              when 'string'
                correct_type = params[ field[:name] ].is_a? String
              when 'numeric'
                correct_type = params[ field[:name] ].is_a? Integer
              when 'int'
                correct_type = params[ field[:name] ].is_a? Integer
            end

            if !correct_type
              raise ValidationException, sprintf("Value [%s] in field [%s] is not of expected type [%s]", params[ field['name'] ], field['name'], field['type'])
            end
          end
        end
      end
    end
    def validate_no_extra_fields(params)
      allowed_fields = TRANSACTION_FIELDS.map {|name, field| name }
      params.each do |key, value|
        raise InternalException, "Field #{key} is not supported" if !allowed_fields.include?(key)
      end
    end

    def validate_card_number(params)
      # puts "validating card nunber with params = #{params.inspect}"
      card_number = params['sg_CardNumber']
      card_number = self.clean_card_number(card_number)
      card_length = card_number.size
      
      raise CardNumberException, "Card number #{card_number} is too short" if card_length < Safecharge::Constants::CARD_NUMBER_MIN_LENGTH
      raise CardNumberException, "Card number #{card_number}  is too long" if card_length > Safecharge::Constants::CARD_NUMBER_MAX_LENGTH

      parity = card_length % 2
      sum = 0;
      for i in  0..card_length
        digit = card_number[i].to_i
        digit = digit * 2 if i % 2 == parity
        digit = digit - 9 if digit > 9
        sum = sum + digit
      end
      valid = (sum % 10 == 0) ? true : false; 
      raise CardNumberException, "Invalid checksum" unless valid

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
          params['sg_CVV2'] = self.pad_string(params['sg_CVV2'], 0, 0, 'x')
        end

        # Replace partially
        if !params['sg_CardNumber'].empty?
          params['sg_CardNumber'] = self.pad_string(params['sg_CardNumber'], 6, 4, 'x')
        end
      end
      server = self.settings['live'] ? Safecharge::Constants::SERVER_LIVE : Safecharge::Constants::SERVER_TEST
      uri = URI(server)
      uri.query = URI.encode_www_form(self.params)
      result = "#{uri.to_s}"

      return result;
    end

    protected

    def http_build_query(params)
      # puts "#{params.inspect}"
      return 'todo-fill-this-in'
    end

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

    def pad_string(string, start_count = nil, end_count =nil, character = nil)
      result = ''
      start_count = self.settings['padFrom'] if start_count == nil
      end_count = self.settings['padTo'] if end_count == nil
      character = self.settings['padWith'] if character == nil
      length = string.size - start_count - end_count
      if length <= 0
        result = string
      else
        replacement = string[end_count].rjust(length, character)
        result = string[0..start_count] < replacement
      end
      return result
    end

  end
end
