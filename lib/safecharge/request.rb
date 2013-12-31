#!/user/bin/env ruby
#coding: utf-8

require "safecharge"
require "safecharge/constants"

module Safecharge
  class Request
    attr_accessor :mode, :params, :items, :url, :full_url

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
      'first_name' => {:required => false, :type => 'string', length: 30},
      'last_name' => {:required => false, :type => 'string', length: 40},
      'city' => {:required => false, :type => 'string', length: 30},
      'country' => {:required => false, :type => 'string', length: 20}

    } # 'time_stamp', 'numberofitems' and 'checksum' are inserted after validation.

    ALLOWED_ITEM_FIELDS = {
      'name' => {:required => true, :type => 'string', length: 400},
      'number' => {:required => true, :type => 'string', length: 400},
      'amount' => {:required => true, :type => 'currency'},
      'quantity' => {:required => true, :type => 'int'},
      'discount' => {:required => false, :type => 'percent'},
      'shipping' => {:required => false, :type => 'currency'},
      'handling' => {:required => false, :type => 'currency'}

    }

    DEFAULT_PARAMS = {
      'merchant_id' => Safecharge::Constants::MERCHANT_ID,
      'merchant_site_id' => Safecharge::Constants::MERCHANT_SITE_ID,
      'currency' => Safecharge::Constants::DEFAULT_CURRENCY_CODE,
      'version' => Safecharge::Constants::API_VERSION,
      'encoding' => Safecharge::Constants::DEFAULT_ENCODING
    }

    def initialize(a_url, some_params = {})
      raise ArgumentError, "missing url" if a_url == nil || a_url.empty?
      if a_url === Safecharge::Constants::SERVER_TEST
        self.mode = 'test'
      elsif a_url === Safecharge::Constants::SERVER_LIVE
        self.mode = 'live'
      else
        raise ArgumentError, "invalid url #{a_url}"
      end
      self.url = a_url
      self.full_url = a_url
      core_params, items, extracted_items = self.extract_items(convert_symbols_to_strings(some_params))
      raise ValidationException, "Missing array of Items." if items == nil || items.empty?
      self.items = items
      self.params = DEFAULT_PARAMS.merge(core_params)
      self.validate_parameters(self.params)
      items.each {|i| self.validate_parameters(i, self.class::ALLOWED_ITEM_FIELDS)}
      self.params.merge!(extracted_items)
      self.params.merge!({'numberofitems' => items.size,
                          'time_stamp' => Time.now.utc.strftime("%Y-%m-%d.%H:%M:%S")})
      self.params.merge!({'checksum' => calculate_checksum})
      self.construct_url
    end

    protected

    def convert_symbols_to_strings(a_hash = {})
      raise ArgumentError, "Expected a Hash" unless a_hash.is_a?(Hash)
      return {} if a_hash.empty?
      result = {}
      a_hash.each do |key, value|
        if value.is_a?(Array)
          result[key.to_s] = value.map { |av| av.is_a?(Hash) ? convert_symbols_to_strings(av) : av }
        elsif value.is_a?(Hash)
          result[key.to_s] = convert_symbols_to_strings(value)
        else
          result[key.to_s] = value
        end
      end
      return result
    end

    def extract_items(params)
      items = params.delete('items')
      return params, nil, nil if items == nil
      keyed_items = {}
      items.each_with_index do |item, i|
        item.keys.each do |key|
          new_key = "item_#{key}_#{i+1}"
          keyed_items[new_key] = item[key]
        end
      end
      return params, items, keyed_items
    end

    def validate_parameters(params, against = self.class::ALLOWED_FIELDS)
      self.validate_fields(params, against)
      self.validate_no_extra_fields(params, against)
    end

    def validate_fields(params, against = self.class::ALLOWED_FIELDS)
      against.each do |name, meta|
        required = (meta[:required] === true)
        # Check that all required parameters are present
        if required && !params.keys.include?(name)
          raise ValidationException, "Parameter #{name} is required, but missing from #{params.keys}"
        end
        if params.keys.include? name
          p = params[name]
          if p != nil
            # Check the type of the value
            correct_type = false
            case meta[:type]
              when 'boolstring'
                correct_type = p.is_a?(String) && ['true', 'false'].include?(p)
              when 'usertoken'
                correct_type = p.is_a?(String) && ['register', 'auto'].include?(p)
              when 'string'
                correct_type = p.is_a? String
                raise ValidationException, sprintf("Value '%s' in field '%s' is too long.", p, name) if p.size > meta[:length]
              when 'currency_code'
                correct_type = p.is_a? String
              when 'currency'
                correct_type = p.is_a?(Float) || p.is_a?(Integer)
              when 'percent'
                correct_type = p.is_a?(Float) || p.is_a?(Integer)
              when 'int'
                correct_type = p.is_a? Integer
            end

            if !correct_type
              raise ValidationException, sprintf("Value '%s' in field '%s' is not of expected type '%s'", p, name, meta[:type])
            end
          end
        end
      end
    end

    def validate_no_extra_fields(params, against = self.class::ALLOWED_FIELDS)
      allowed_fields = against.keys
      params.each do |key, value|
        raise InternalException, "Field #{key} is not supported" if !allowed_fields.include?(key)
      end
    end

    def calculate_checksum
      codes = [Safecharge::Constants::SECRET_KEY,
              self.params['merchant_id'],
              self.params['currency'],
              self.params['total_amount']]
      self.items.each do |item|
        codes << item['name']
        codes << item['amount']
        codes << item['quantity']
      end
      codes << self.params['time_stamp']
      s = codes.join('')
      return Digest::MD5.hexdigest(s)
    end

    def construct_url
      uri = URI(self.url)
      uri.query = URI.encode_www_form(self.params)
      self.full_url = uri.to_s
      return uri
    end

#     def calculate_item_total
#      # item_amount_N - item_discount_N + item_shipping_N + item_handling_N) * item_quantity_N
#      return 0.0 if self.items == nil || self.items.empty?
#      result = 0
#      self.items.each {|i| result += (i['amount'] +
#                                       i['shipping'] +
#                                       i['handling'] -
#                                       i['discount']) * i['quantity']}
#       return result
#     end
#     
#     def calculate_total_with_tax
#       # calculatedTotalAmount+=shipping+handling-discount
#       tot = calculate_item_total +
#             self.fields['shipping'] +
#             self.fields['handling'] - self.fields['discount']
#       return tot, tot * ( self.fields['total_tax'] / 100)
#     end

  end
end
