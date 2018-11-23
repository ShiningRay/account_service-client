require 'oauth2'

module BitRabbit::AccountService
  module OAuth
    class Client < ::OAuth2::AccessToken
      BaseURL = '/oauth/v1'
      def transfer(sn:, currency:, to:, amount:)
        body = {
          sn: sn,
          currency: currency,
          amount: amount
        }
        if to.is_a?(Numeric)
          body[:to_member_id] = to
        else
          body[:to_member] = to
        end
        res = post("#{BaseURL}/transfers", body: body).parsed
        if res['success']
          res['data']
        else
          raise res['errors']
        end
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