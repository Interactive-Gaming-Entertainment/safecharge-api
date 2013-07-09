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

	def request(params = {}, mode = 'test')
		result = nil
		url = ''
		case mode
		  when 'test'
		    url = Safecharge::Cosntants::SERVER_TEST
		  when 'live'
		    url = Safecharge::Cosntants::SERVER_LIVE
      else
        raise ArgumentException, "Invalid request mode #{mode}"
    end

		begin
			request = Safecharge::Request.new(url, params)
			request = request.send
			puts "Parsing response"
			response = Safecharge::Response.new
			result = response.parse(request)
			puts "Result: #{result.inspect}"
			return result

		rescue NetworkException => e
		  puts "Caught NetworkException. #{e.message}"
		  puts e.backtrace.join('\n')
			raise RuntimeError, "Gateway communications error. Please try again later."

		rescue InternalException => e
			puts "Caught Internal Exception: #{e.message}"
		  puts e.backtrace.join('\n')
			raise RuntimeError, "Internal server error. Please try again later."

		rescue ResponseException => e
			puts "Caught Response Exception: #{e.message}"
		  puts e.backtrace.join('\n')
			raise RuntimeError, "Internal server error. Please try again later."

		rescue ValidationException => e
			puts "Caught Validation Exception: #{e.message}"
		  puts e.backtrace.join('\n')
			raise RuntimeError, "Validation error: #{e.message}. Fix your data and retry."

		rescue SafechargeError => e
			puts "Caught General Safecharge Error: #{e.message}"
		  puts e.backtrace.join('\n')
			raise RuntimeError, "Undocumented Internal error: #{e.message}"
		end
  end
end
