module BitRabbit::AccountService
  module OAuth
    class Client < ::OAuth2::AccessToken
      BaseURL = '/oauth/v1'
      def transfer(currency:, to:, amount:)
        post("#{BaseURL}/transfers", body: {
                  currency: currency,
                  to: to,
                  amount: amount
                }).parsed
      end

      def me
        get("#{BaseURL}/me").parsed
      end
    end
  end
end