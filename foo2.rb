#!/bin/env ruby
## foo2.rb - send 2 requests at the same time to see if cookie value is used in encryption

require 'net/http'
require 'openssl'
require 'pry'

TARGET = 'https://friendzone.red/js/js/index.php'

def log(message, level = :debug)
  puts sprintf('[%s] [%5s] %s', Time.now.strftime('%H:%M.%S'), level.to_s.upcase!, message)
  exit(1) if level.eql?(:fatal)
end

def get(zonedman)
  uri = URI.parse(TARGET)
  
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Get.new(uri.request_uri)
  request['Cookie'] = sprintf('zonedman=%s', zonedman)

  response = http.request(request)

  date   = response['Date']
  cipher = $1 if response.body.match(/\/p>(\w+)<!/)

  log(sprintf('date[%s] zonedman[%s] cipher[%s]', date, zonedman, cipher))
end

def send2withsame
  get('foo')
  get('foo')
end

def send2withdifferent
  get('foo')
  get('bar')
end

binding.pry
