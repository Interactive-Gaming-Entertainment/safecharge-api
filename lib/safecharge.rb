#!/user/bin/env ruby
#coding: utf-8

require "safecharge/version"
require "safecharge/constants"
require "safecharge/request"

module Safecharge

  # define errors and exceptions.
  class SafechargeError < RuntimeError
  end
  class NetworkException < SafechargeError
  end
	class InternalException < SafechargeError
  end
	class ResponseException < SafechargeError
  end
	class ValidationException < SafechargeError
  end
	class CardNumberException < SafechargeError
  end

  # shortcuts
  REQUEST_TYPE_AUTH   = Safecharge::Constants::REQUEST_TYPE_AUTH
  REQUEST_TYPE_SETTLE = Safecharge::Constants::REQUEST_TYPE_SETTLE
  REQUEST_TYPE_SALE   = Safecharge::Constants::REQUEST_TYPE_SALE
  REQUEST_TYPE_CREDIT = Safecharge::Constants::REQUEST_TYPE_CREDIT
  REQUEST_TYPE_VOID   = Safecharge::Constants::REQUEST_TYPE_VOID
  REQUEST_TYPE_AVS    = Safecharge::Constants::REQUEST_TYPE_AVS

  RESPONSE_STATUS_APPROVED = Safecharge::Constants::RESPONSE_STATUS_APPROVED
  RESPONSE_STATUS_SUCCESS  = Safecharge::Constants::RESPONSE_STATUS_SUCCESS
  RESPONSE_STATUS_DECLINED = Safecharge::Constants::RESPONSE_STATUS_DECLINED
  RESPONSE_STATUS_ERROR    = Safecharge::Constants::RESPONSE_STATUS_ERROR
  RESPONSE_STATUS_PENDING  = Safecharge::Constants::RESPONSE_STATUS_PENDING

  DEFAULT_SETTINGS = {
    'username' => Safecharge::Constants::REQUEST_DEFAULT_USERNAME,
    'password' => Safecharge::Constants::REQUEST_DEFAULT_PASSWORD,
    'timeout' => Safecharge::Constants::REQUEST_DEFAULT_TIMEOUT,
    'live' => Safecharge::Constants::REQUEST_DEFAULT_LIVE,
    'log' => '',
    'padFrom' => Safecharge::Constants::DEFAULT_PAD_FROM,
    'padTo' => Safecharge::Constants::DEFAULT_PAD_TO,
    'padWith' => Safecharge::Constants::DEFAULT_PAD_WITH,
    'instanceId' => (1..100000).to_a.sample
  }

	def request(type, settings = {})
		result = nil

		begin
			request = Safecharge::Request.new(settings)

			query_id = request.id
			puts "#{query_id} Starting new #{type} query"

			request.type = type
			request.settings = settings

			query_url = request.url
			puts "#{query_id} Sending query: #{query_url}"
			request = request.send

			puts "#{query_id} Parsing response"
			response = Safecharge::Response.new
			result = response.parse(request)
			puts "#{query_id} Result: #{result.inspect}"
		
		rescue NetworkException => e
		  puts "#{query_id} Caught NetworkException. #{e.message}"
		  puts e.backtrace.join('\n')
			raise RuntimeError, "Gateway communications error. Please try again later."

		rescue InternalException => e
			puts "#{query_id} Caught Internal Exception: #{e.message}"
		  puts e.backtrace.join('\n')
			raise RuntimeError, "Internal server error. Please try again later."

		rescue ResponseException => e
			puts "#{query_id} Caught Response Exception: #{e.message}"
		  puts e.backtrace.join('\n')
			raise RuntimeError, "Internal server error. Please try again later."

		rescue ValidationException => e
			puts "#{query_id} Caught Validation Exception: #{e.message}"
		  puts e.backtrace.join('\n')
			raise RuntimeError, "Validation error: #{e.message}. Please correct your data and try again."

		rescue CardNumberException => e
			puts "#{query_id} Caught Card Number Exception: #{e.message}"
		  puts e.backtrace.join('\n')
			raise RuntimeError, "Credit card number is invalid. Please correct and try again."
		rescue RuntimeError => e
			puts "#{query_id} Caught Exception: #{e.message}"
		  puts e.backtrace.join('\n')
			raise RuntimeError, "Internal server error. Please try again later"
		end

		return result
  end
end
