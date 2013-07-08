#!/user/bin/env ruby
#coding: utf-8

require "safecharge"
require "safecharge/constants"
require "safecharge/request"
require 'ox'

module Safecharge
  class Response
    attr_accessor :query_id, :request, :response
        
    def initialize(request = nil)
      self.request = request
      self.query_id = (self.request) ? self.request.id : nil
      self.response = (self.request) ? self.request.response : nil
      self.validate(self.response)
    end
    
	def validate(response)
		response.trim!
    raise ResponseException, "Empty response" if response.empty?

    begin
      xml = Ox.parse(response)

    rescue => e
      puts "caught error: #{e.message}"
      puts e.backtrace.join('\n')
      raise ResponseException, "Failed to validate XML response"
    end
  end
  
  def parse(request)
		data = nil
		response = request.response.trim
    self.query_id = request.id
		self.validate response

		begin
			data = new Ox.parse(response)

		rescue => e
		  puts "Caught error: #{e.message}"
			raise ResponseException, "Failed to parse XML response: #{e.message}"
		}

		return nil if data.empty?
		return data
	}
  end
end
