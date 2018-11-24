# frozen_string_literal: true
require "base64"
require "openssl"
require "account_service/client/version"
require "typhoeus"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/object/to_param"
require "active_support/json"

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
  end
end
