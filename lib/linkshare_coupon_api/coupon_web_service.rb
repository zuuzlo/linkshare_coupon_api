require "addressable/uri"
require "httparty"

module LinkshareCouponApi
  # For implementation details please visit
  # http://helpcenter.linkshare.com/publisher/questions.php?questionid=865
  class CouponWebService
    include HTTParty

    attr_reader :api_base_url, :api_timeout, :token

    def initialize
      @token        = LinkshareCouponApi.token
      @api_base_url = LinkshareCouponApi::WEB_SERVICE_URIS[:coupon_web_service]
      @api_timeout  = LinkshareCouponApi.api_timeout

      if @token.nil?
        raise AuthenticationError.new(
          "No token. Set your token by using 'LinkshareAPI.token = <TOKEN>'. " +
          "You can retrieve your token from LinkhShare's Web Services page under the Links tab. " +
          "See http://helpcenter.linkshare.com/publisher/questions.php?questionid=648 for details."
        )
      end
    end

    def query(params)
      raise ArgumentError, "Hash expected, got #{params.class} instead" unless params.is_a?(Hash)

      params.merge!(token: token)
      begin
        response = self.class.get(
          api_base_url,
          query: params,
          timeout: api_timeout
        )
      rescue Timeout::Error
        raise ConnectionError.new("Timeout error (#{timeout}s)")
      end

      if response.code != 200
        raise Error.new(response.message, response.code)
      end
      error = response["fault"]
      raise InvalidRequestError.new(error["errorstring"], error["errorcode"].to_i) if error

      Response.new(response)
    end
  end
end
