module BitRabbit
  module AccountService
    class MultiErrors < StandardError
      def initialize(errors)
        @errors = Array(errors)
        @errors.each_with_index do |err, i|
          @errors[i] = { message: err } if err.is_a?(String)
        end
      end

      def message
        @errors.map { |err| err[:message] }.join("\n")
      end
    end
    module RequestHelpers
      def build_sig(method, path, body_str, headers)
        md5 = Digest::MD5.hexdigest(body_str)
        c = [
          method.to_s.upcase,
          path,
          md5,
          headers['Content-Type'],
          headers['Date']
        ].join("\n")
        Base64.strict_encode64(OpenSSL::HMAC.digest('sha1', @secret, c))
      end

      def request(method, path, body = '')
        body_str = body.is_a?(String) ? body : ActiveSupport::JSON.encode(body)

        headers = {
          'Content-Type' => 'application/json',
          'Date' => Time.new.utc.strftime('%a, %d %b %Y %T %Z')
        }
        md5 = body.blank? ? '' : Digest::MD5.hexdigest(body_str)
        c = [
          method.to_s.upcase,
          path,
          md5,
          headers['Content-Type'],
          headers['Date']
        ].join("\n")
        puts c.inspect
        sig = Base64.strict_encode64(OpenSSL::HMAC.digest('sha1', @secret, c))
        puts sig.inspect

        headers['Authorization'] = "BRB #{@key}:#{sig}"

        req = Typhoeus::Request.new(
          File.join(@base_url, path), method: method,
                                      body: body_str,
                                      headers: headers,
                                      timeout: @timeout || 60
        )
        res = req.run
        puts res.response_body.to_s
        json = ActiveSupport::JSON.decode res.response_body.to_s
        if json['success']
          json['data']
        else
          raise MultiErrors, json['errors']
        end
      end

      def post(path, body, query = nil)
        request(:post, query ? "#{path}?#{query.to_param}" : path.to_s, body)
      end

      def get(path, query = nil)
        request(:get, query ? "#{path}?#{query.to_param}" : path.to_s)
      end
    end
  end
end
