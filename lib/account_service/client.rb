# frozen_string_literal: true
require "base64"
require "openssl"
require "account_service/client/version"
require "typhoeus"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/object/to_param"
require "active_support/json"
require 'jwt'

require_relative 'request_helpers'
require_relative 'oauth/client'

module BitRabbit::AccountService
  class Client
    include RequestHelpers
    def initialize(key, secret, base_url='https://accounts.bitrabbit.com')
      @key = key
      @secret = secret
      @base_url = base_url
    end

    def currencies
      get '/api/v1/currencies'
    end

    def members(ids)
      get "/api/v1/members/#{ids.join(",")}"
    end

    def get_member(id)
      get "/api/v1/members/#{id}"
    end

    def get_invitees(member_id:, after:)
      params = {date: after}
      get "/api/v1/members/#{member_id}/invitees", params
    end

    def transfer(sn:, from:, to:, amount:, currency:)
      transfer_params = {
        sn: sn,
        amount: amount,
        currency: currency
      }

      if from.is_a?(Numeric)
        transfer_params[:from_member_id] = from
      else
        transfer_params[:from_member] = from
      end

      if to.is_a?(Numeric)
        transfer_params[:to_member_id] = to
      else
        transfer_params[:to_member] = to
      end

      post "/api/v1/transfers", transfer_params
    end

    def extract_event(request)
      if request.headers['Authorization'] =~ /\ABRB (\w+):(.+)\z/
        key = $1
        sig = $2
        headers = {
          "Content-Type" => "application/json",
          "Date" => request.headers['Date']
        }

        date = DateTime.httpdate(request.headers['Date'])
        raise 'Request Expired' if date < 10.minutes.ago

        body = request.body.read

        if sig != build_sig(request.method, request.original_url, body, headers)
          raise 'Signature Mismatch'
        end
        return ActiveSupport::JSON.decode body
      else
        raise 'Missing Authorization Information'
      end
    end

    def checkout_token(opts={})
      opts.to_options!
      opts.assert_valid_keys(:order_no, :amount, :currency, :redirect_url)
      opts = opts.slice(:order_no, :amount, :currency, :redirect_url)
      opts[:iss] = @key
      opts[:iat] = Time.now.to_i
      token = JWT.encode opts, @secret, 'HS256'
    end

    def decode_token(token)
      data = JWT.decode(token, @secret, "HS256")
      payload = data[0]
      raise 'App Key Mismatch' if payload['iss'] != @key
      payload
    end

    def checkout_url(opts={})
      token = checkout_token(opts)
      File.join(@base_url, "/checkout?token=#{token}")
    end

    def deposits(currency:, label:, page: 1, start_at: nil, end_at: nil)
      params = {currency: currency, label: label, page: page, start: start_at, end: end_at}
      res = get("#{BaseURL}/deposits", params)
    end

    def withdraws(currency:, label:, page: 1, start_at: nil, end_at: nil)
      params = {currency: currency, label: label, page: page, start: start_at, end: end_at}
      res = get("#{BaseURL}/withdraws", params)
    end

    def send_withdraw(currency:, label:, amount:, address:)
      payload = {currency: currency, label: label, amount: amount, address: address}
      res = post("#{BaseURL}/withdraws", params)
    end

    def addresses(currency:)
      res = get("#{BaseURL}/addresses")
    end

    def address(currency:, label:)
      params = {currency: currency}

      res = get("#{BaseURL}/addresses/#{label}", params)
    end

  end
end
