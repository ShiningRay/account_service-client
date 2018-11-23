require 'oauth2'

module BitRabbit::AccountService
  module OAuth
    class Client < ::OAuth2::AccessToken
      BaseURL = '/oauth/v1'
      def transfer(sn:, currency:, to:, amount:, two_factor: nil)
        body = {
          sn: sn,
          currency: currency,
          amount: amount,
          two_factor: two_factor
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

      def send_sms_verification
        res = post("#{BaseURL}/two_factors/send_sms_code").parsed
        if res['success']
          res['data']
        else
          raise res['errors']
        end
      end

      def verify_two_factor(two_factor_params)
        res = post("#{BaseURL}/two_factors/verify", body: {two_factor: two_factor_params}).parsed
        res['success']
      end
    end
  end
end