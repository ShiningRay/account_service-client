require "account_service/client/version"

module AccountService
  class Client
    def initialize(key, secret)
      @key = key
      @secret = secret
    end
  end
end
