require 'openssl'

module Telex
  module ApiKey
    extend self

    def generate(raw_key)
      OpenSSL::HMAC.hexdigest("sha256", Config.api_key_hmac_secret, raw_key)
    end

    def compare(encrypted_key, given_key)
      time_constant_compare(encrypted_key, generate(given_key))
    end

    private

    def time_constant_compare(a, b)
      check = a.bytesize ^ b.bytesize
      a.bytes.zip(b.bytes) { |x,y| check |= x^y }
      check == 0
    end
  end
end
