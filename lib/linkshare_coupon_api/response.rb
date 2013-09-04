require "recursive_open_struct"

module LinkshareCouponApi
  class Response
    attr_reader :total_matches, :total_pages, :page_number_requested, :data, :request

    def initialize(response)
      @request = response.request
      result = response["couponfeed"]

      @total_matches = result["TotalMatches"].to_i
      @total_pages = result["TotalPages"].to_i
      @page_number_requested = result["PageNumberRequested"].to_i
      @data = parse(result["link"])
    end

    def all
      while page_number_requested < total_pages
        uri = Addressable::URI.parse(request.uri)
        params = uri.query_values
        params["pagenumber"] = page_number_requested + 1
        next_page_response = LinkshareCouponApi::CouponWebService.new.query(params)
        @page_number_requested = next_page_response.page_number_requested
        @data += next_page_response.data
      end
      @data
    end

    private

    def parse(raw_data)
      data = []
      data = [RecursiveOpenStruct.new(raw_data)] if raw_data.is_a?(Hash) # If we got exactly one result, put it in an array.
      raw_data.each { |i| data << RecursiveOpenStruct.new(i) } if raw_data.is_a?(Array)
      data
    end
  end
end
