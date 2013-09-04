require "linkshare_coupon_api/version"

require "linkshare_coupon_api/coupon_web_service"
require "linkshare_coupon_api/response"

require "linkshare_coupon_api/errors/error"
require "linkshare_coupon_api/errors/authentication_error"
require "linkshare_coupon_api/errors/connection_error"
require "linkshare_coupon_api/errors/invalid_request_error"

module LinkshareCouponApi
  WEB_SERVICE_URIS = { coupon_web_service: "http://couponfeed.linksynergy.com/coupon" }

  @api_timeout = 30

  class << self
    attr_accessor :token
    attr_reader :api_timeout
  end

  def self.api_timeout=(timeout)
    raise ArgumentError, "Timeout must be a Fixnum; got #{timeout.class} instead" unless timeout.is_a? Fixnum
    raise ArgumentError, "Timeout must be > 0; got #{timeout} instead" unless timeout > 0
    @api_timeout = timeout
  end

  def self.coupon_web_service(options = {})
    coupon_web_service = LinkshareCouponApi::CouponWebService.new
    coupon_web_service.query(options)
  end
end
