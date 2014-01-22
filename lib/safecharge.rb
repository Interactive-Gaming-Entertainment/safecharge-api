#!/user/bin/env ruby
#coding: utf-8

require "safecharge/version"
require "safecharge/constants"
require "safecharge/request"
require "safecharge/wc_request"
require "safecharge/response"
require "safecharge/dmn"

# The Safecharge PPP system provides a simple means for merchants to integrate credit card
# payments into their site, without worrying about having to capture their customers'
# credit card details.
# 
# It works like this:
# 
# Step 1) Your website provides a way for customers to choose the items they wish to buy,
#         say via a shopping basket, or similar.
#         
#         Collate an array of items with the following information
#         
#         items = [
#           {
#           'name' => 'bat',
#           'number' => 'sku54321',
#           'amount' => 25,
#           'quantity' => 1
#           },
#           {
#           'name' => 'ball',
#           'number' => 'sku12345',
#           'amount' => 15,
#           'quantity' => 2
#           }
#         ]
#
#         and insert that items array into an array of params like so
#
#         params = {
#           'total_amount' => 55,
#           'currency' => 'USD',
#           'items' => items
#         }
#
#         Note you must supply the following environment variables for this API to work.
# 
#         SAFECHARGE_SECRET_KEY, SAFECHARGE_MERCHANT_ID, SAFECHARGE_MERCHANT_SITE_ID
#
#         These will have been provided to you by Safecharge.
#
# Step 2) You offer a 'checkout' button that links to the following url.
#
#         url = Safecharge.request_url(params)
#
# Step 3) The Safecharge system will redirect the user to the Public Payment Page
#         and there they will enter in their credit card and other payment details as needed.
#         When the user confirms their payment, the Safecharge system authenticates it and
#         redirects the user to either a 'success', 'failure' or 'back' page. The back page
#         is used if the user suspends the payment processing by clicking on their browser's
#         back button.
#         Whichever page is returned, it will incude parameters from the server
#         which can be decoded into a valid Response object by your server.
#
#         response = Safecharge.parse_response
#
# TODO: finish these docs
#
module Safecharge

  # define errors and exceptions.
  class SafechargeError < RuntimeError
  end
  class InternalException < SafechargeError
  end
  class ValidationException < SafechargeError
  end

  # module level method to get the redirection URL given some params.
  # you must explicitly set the mode to 'live' to generate the production URL.
  def self.request_url(params = {}, mode = 'test')
    result = nil
    url = ''
    case mode
      when 'test'
        url = Safecharge::Constants::SERVER_TEST
      when 'live'
        url = Safecharge::Constants::SERVER_LIVE
      else
        raise ArgumentError, "Invalid request mode #{mode}"
    end

    begin
      request = Safecharge::Request.new(url, params)
      return request.full_url

    rescue InternalException => e
      puts "Caught Internal Exception: #{e.message}"
      puts e.backtrace
      raise RuntimeError, "Internal server error. Please try again later."

    rescue ValidationException => e
      puts "Caught Validation Exception: #{e.message}"
      puts e.backtrace
      raise RuntimeError, "Validation error: #{e.message} Fix your data and retry."

    rescue SafechargeError => e
      puts "Caught General Safecharge Error: #{e.message}"
      puts e.backtrace
      raise RuntimeError, "Undocumented Internal error: #{e.message}"
    end
  end

  # module level method to get the redirection URL given some params.
  # you must explicitly set the mode to 'live' to generate the production URL.
  def self.wc_request_url(params = {}, mode = 'test')
    result = nil
    url = ''
    case mode
      when 'test'
        url = Safecharge::Constants::SERVER_TEST
      when 'live'
        url = Safecharge::Constants::SERVER_LIVE
      else
        raise ArgumentError, "Invalid request mode #{mode}"
    end

    begin
      request = Safecharge::WcRequest.new(url, params)
      return request.full_url

    rescue InternalException => e
      puts "Caught Internal Exception: #{e.message}"
      puts e.backtrace
      raise RuntimeError, "Internal server error. Please try again later."

    rescue ValidationException => e
      puts "Caught Validation Exception: #{e.message}"
      puts e.backtrace
      raise RuntimeError, "Validation error: #{e.message} Fix your data and retry."

    rescue SafechargeError => e
      puts "Caught General Safecharge Error: #{e.message}"
      puts e.backtrace
      raise RuntimeError, "Undocumented Internal error: #{e.message}"
    end
  end

  # module level method to get the redirection URL given some params.
  # you must explicitly set the mode to 'live' to generate the production URL.
  def self.sg_request_url(params = {}, mode = 'test')
    result = nil
    url = ''
    case mode
      when 'test'
        url = Safecharge::Constants::SG_SERVER_TEST
      when 'live'
        url = Safecharge::Constants::SG_SERVER_LIVE
      else
        raise ArgumentError, "Invalid request mode #{mode}"
    end

    begin
      request = Safecharge::SgRequest.new(url, params)
      return request.full_url

    rescue InternalException => e
      puts "Caught Internal Exception: #{e.message}"
      puts e.backtrace
      raise RuntimeError, "Internal server error. Please try again later."

    rescue ValidationException => e
      puts "Caught Validation Exception: #{e.message}"
      puts e.backtrace
      raise RuntimeError, "Validation error: #{e.message} Fix your data and retry."

    rescue SafechargeError => e
      puts "Caught General Safecharge Error: #{e.message}"
      puts e.backtrace
      raise RuntimeError, "Undocumented Internal error: #{e.message}"
    end
  end

end
