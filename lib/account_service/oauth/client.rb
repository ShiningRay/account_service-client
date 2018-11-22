require 'oauth2'

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

      def accounts
        res = get("#{BaseURL}/accounts").parsed
        if res['success']
          res['data']
        else
          raise res['errors']
        end
      end

      alias get_accounts accounts

      def two_factors
        res = get("#{BaseURL}/two_factors").parsed
        if res['success']
          res['data']
        else
          raise res['errors']
        end
      end
    end
  end
end