#!/bin/env ruby
# foo.rb doing some decryption
require 'openssl'


encrypted = 'T0lNRlhxdzR6STE2NjI0MTA0NDQxTTk2TXJsaVhi'
key = 'justgotzoned'
iv = '1662410444'

decipher = OpenSSL::Cipher::AES.new(128, :CBC)
decipher.decrypt
decipher.key = key
decipher.iv  = iv

plain = decipher.update(encrypted) + decipher.plain

puts plain

