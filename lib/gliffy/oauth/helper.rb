# Gliffy OAuth implementation is screwed  - longer nonce values causes
# it to complain about the  timestamp value; we're limiting the length
# to 25 characters here
module OAuth
  module Helper
    def generate_key(size=25)
      Base64.encode64(OpenSSL::Random.random_bytes(size)).gsub(/\W/, '')
    end
  end
end
