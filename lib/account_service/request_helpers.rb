module BitRabbit
  module AccountService
    module RequestHelpers
      def request(method, path, body = "")
        body_str = body.is_a?(String) ? body : ActiveSupport::JSON.encode(body)

        headers = {
          "Content-Type" => "application/json",
          "Date" => Time.new.utc.strftime("%a, %d %b %Y %T %Z"),
        }
        md5 = body.blank? ? "" : Digest::MD5.hexdigest(body_str)
        c = [
          method.to_s.upcase,
          path,
          md5,
          headers["Content-Type"],
          headers["Date"],
        ] * "\n"
        puts c.inspect
        sig = Base64.strict_encode64(OpenSSL::HMAC.digest("sha1", @secret, c))
        puts sig.inspect

        headers["Authorization"] = "BRB #{@key}:#{sig}"

        req = Typhoeus::Request.new(
          File.join(@base_url, path), method: method,
                                      body: body_str,
                                      headers: headers,
        )
        res = req.run
        puts res.response_body.to_s
        ActiveSupport::JSON.decode res.response_body.to_s
      end

      def post(path, body, query = nil)
        request(:post, query ? "#{path}?#{query.to_param}" : "#{path}", body)
      end

      def get(path, query = nil)
        request(:get, query ? "#{path}?#{query.to_param}" : "#{path}")
      end
    end
  end
end