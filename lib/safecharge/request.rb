#!/user/bin/env ruby
#coding: utf-8

require "safecharge"
require "safecharge/constants"

module Safecharge
  class Request
    attr_accessor :mode, :params, :items, :url, :full_url

    ALLOWED_FIELDS = {
      'currency' => {:required => true, :type => 'currency_code'},
      'customData' => {:required => false, :type => 'string'},
      'customSiteName' => {:required => false, :type => 'string'},
      'discount' => {:required => false, :type => 'currency'},
      'encoding' => {:required => false, :type => 'string'},
      'error_url' => {:required => false, :type => 'string'},
      'handling' => {:required => false, :type => 'currency'},
      'invoice_id' =>  {:required => false, :type => 'string'},
      'merchant_id' => {:required => true, :type => 'int'},
      'merchant_site_id' => {:required => true, :type => 'int'},
      'merchant_unique_id' => {:required => false, :type => 'string'},
      'merchantLocale' => {:required => false, :type => 'string'},
      'payment_method' => {:required => false, :type => 'string'},
      'pending_url' => {:required => false, :type => 'string'},
      'productId' => {:required => false, :type => 'string'},
      'shipping' => {:required => false, :type => 'currency'},
      'skip_billing_tab' => {:required => false, :type => 'string'},
      'skip_review_tab' => {:required => false, :type => 'string'},
      'success_url' => {:required => false, :type => 'string'},
      'total_amount' => {:required => true, :type => 'currency'},
      'total_tax' => {:required => false, :type => 'percent'},
      'userid' => {:required => false, :type => 'string'},
      'version' => {:required => true, :type => 'string'},
      'webMasterId' => {:required => false, :type => 'string'}

    } # 'time_stamp', 'numberofitems' and 'checksum' are inserted after validation.

    ALLOWED_ITEM_FIELDS = {
      'name' => {:required => true, :type => 'string'},
      'number' => {:required => true, :type => 'string'},
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

    def initialize(url, params = {})
      raise ArgumentError, "missing url" if url == nil || url.empty?
      if url === Safecharge::Constants::SERVER_TEST
        self.mode = 'test'
      elsif url === Safecharge::Constants::SERVER_LIVE
        self.mode = 'live'
      else
        raise ArgumentError, "invalid url #{url}"
      end
      self.url = url
      self.full_url = url
      core_params, items, extracted_items = self.extract_items(params)
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
                correct_type = p.is_a?(String) && ['True', 'False'].include?(p)
              when 'string'
                correct_type = p.is_a? String
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
