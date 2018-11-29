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
          raise res['errors'].join("\n")
        end
      end

      # Refreshes the current Access Token
      #
      # @return [AccessToken] a new AccessToken
      # @note options should be carried over to the new AccessToken
      def refresh!(params = {})
        raise('A refresh_token is not available') unless refresh_token
        params[:grant_type] = 'refresh_token'
        params[:refresh_token] = refresh_token
        new_token = @client.get_token(params, {}, self.class)
        new_token.options = options
        new_token.refresh_token = refresh_token unless new_token.refresh_token

        new_token
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

      def invitees(after:nil)
        p = {date: after} if after
        res = get("#{BaseURL}/invitees", p).parsed
        if res['success']
          res['data']
        else
          raise res['errors']
        end
      end

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