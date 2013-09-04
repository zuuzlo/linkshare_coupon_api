require "test_helper"

class LinkshareCouponApiTest < Test::Unit::TestCase
  def test_coupon_web_service_invalid_token
    LinkshareCouponApi.token = nil
    assert_raise LinkshareCouponApi::AuthenticationError do
      LinkshareCouponApi.coupon_web_service(network: 1, mid: 38605)
    end
  end

  def test_coupon_web_service_internal_error
    LinkshareCouponApi.token = token
    xml_response = <<-XML
      <?xml version="1.0" encoding="UTF-8"?>
        <fault>
          <errorcode>10</errorcode>
          <errorstring>Internal Error Unable To Process Request At This Time</errorstring>
        </fault>
    XML
    stub_request(
      :get,
      "http://couponfeed.linksynergy.com/coupon?network=1&token=#{token}"
      ).
      to_return(
        status: 200,
        body: xml_response,
        headers: { "Content-type" => "text/xml; charset=UTF-8" }
    )
    e = assert_raise LinkshareCouponApi::InvalidRequestError do
      LinkshareCouponApi.coupon_web_service(network: 1)
    end
    assert_equal 10, e.code
    assert_equal "Internal Error Unable To Process Request At This Time", e.message
  end

  def test_coupon_web_service_usage_limited
    LinkshareCouponApi.token = token
    xml_response = <<-XML
      <?xml version="1.0" encoding="UTF-8"?>
        <fault>
          <errorcode>30</errorcode>
          <errorstring>Usage Quota Exceeded</errorstring>
        </fault>
    XML
    stub_request(
      :get,
      "http://couponfeed.linksynergy.com/coupon?network=1&token=#{token}"
      ).
      to_return(
        status: 200,
        body: xml_response,
        headers: { "Content-type" => "text/xml; charset=UTF-8" }
    )
    e = assert_raise LinkshareCouponApi::InvalidRequestError do
      LinkshareCouponApi.coupon_web_service(network: 1)
    end
    assert_equal 30, e.code
    assert_equal "Usage Quota Exceeded", e.message
  end

  def test_coupon_web_service_invalid_parameters
    LinkshareCouponApi.token = token
    xml_response = <<-XML
      <?xml version="1.0" encoding="UTF-8"?>
        <fault>
          <errorcode>40</errorcode>
          <errorstring>Invalid Request</errorstring>
        </fault>
    XML
    stub_request(
      :get,
      "http://couponfeed.linksynergy.com/coupon?network=15&token=#{token}"
      ).
      to_return(
        status: 200,
        body: xml_response,
        headers: { "Content-type" => "text/xml; charset=UTF-8" }
    )
    e = assert_raise LinkshareCouponApi::InvalidRequestError do
      LinkshareCouponApi.coupon_web_service(network: 15)
    end
    assert_equal 40, e.code
    assert_equal "Invalid Request", e.message
  end

  def test_coupon_web_service_invalid_or_not_approved_token
    LinkshareCouponApi.token = token
    xml_response = <<-XML
      <?xml version="1.0" encoding="UTF-8"?>
        <fault>
          <errorcode>20</errorcode>
          <errorstring>Access Denied Token ID Is Invalid or Not Approved for Coupon Feed</errorstring>
        </fault>
    XML
    stub_request(
      :get,
      "http://couponfeed.linksynergy.com/coupon?network=15&token=#{token}"
      ).
      to_return(
        status: 200,
        body: xml_response,
        headers: { "Content-type" => "text/xml; charset=UTF-8" }
    )
    e = assert_raise LinkshareCouponApi::InvalidRequestError do
      LinkshareCouponApi.coupon_web_service(network: 15)
    end
    assert_equal 20, e.code
    assert_equal "Access Denied Token ID Is Invalid or Not Approved for Coupon Feed", e.message
  end

  def test_coupon_web_service_with_no_results
    LinkshareCouponApi.token = token
    xml_response = <<-XML
      <?xml version="1.0" encoding="UTF-8"?>
        <couponfeed>
          <TotalMatches>0</TotalMatches>
          <TotalPages>0</TotalPages>
          <PageNumberRequested>1</PageNumberRequested>
        </couponfeed>
    XML
    stub_request(
      :get,
      "http://couponfeed.linksynergy.com/coupon?network=1&promotiontype=30&token=#{token}"
      ).
      to_return(
        status: 200,
        body: xml_response,
        headers: { "Content-type" => "text/xml; charset=UTF-8" }
    )
    response = LinkshareCouponApi.coupon_web_service(network: 1, promotiontype: 30)
    assert_equal 0, response.total_matches
    assert_equal 0, response.total_pages
    assert_equal 1, response.page_number_requested
    assert_equal [], response.data
  end

  def test_coupon_web_service_with_valid_response
    LinkshareCouponApi.token = token
    xml_response = <<-XML
      <?xml version="1.0" encoding="UTF-8"?>
      <couponfeed><TotalMatches>20</TotalMatches><TotalPages>7</TotalPages><PageNumberRequested>1</PageNumberRequested><link type="TEXT"><categories><category id="1">Apparel</category><category id="20">House wares</category><category id="21">Jewelry &amp; Accessories</category></categories><promotiontypes><promotiontype id="7">Free Shipping</promotiontype></promotiontypes><offerdescription>Free Shipping!</offerdescription><offerstartdate>2013-08-30</offerstartdate><offerenddate>2013-09-09</offerenddate><couponrestriction>On Orders Over $75</couponrestriction><clickurl>http://click.linksynergy.com/fs-bin/click?id=V8uMkWlCTes&amp;offerid=297133.410&amp;type=3&amp;subid=0</clickurl><impressionpixel>http://ad.linksynergy.com/fs-bin/show?id=V8uMkWlCTes&amp;bids=297133.410&amp;type=3&amp;subid=0</impressionpixel><advertiserid>38605</advertiserid><advertisername>Kohls Department Stores Inc</advertisername><network id="1">US Network</network></link><link type="TEXT"><categories><category id="12">Department Store</category></categories><promotiontypes><promotiontype id="1">General Promotion</promotiontype></promotiontypes><offerdescription>Take an Extra 15% off your order when you use your Kohl's Charge card!</offerdescription><offerstartdate>2013-08-08</offerstartdate><offerenddate>2016-08-01</offerenddate><clickurl>http://click.linksynergy.com/fs-bin/click?id=V8uMkWlCTes&amp;offerid=297133.133&amp;type=3&amp;subid=0</clickurl><impressionpixel>http://ad.linksynergy.com/fs-bin/show?id=V8uMkWlCTes&amp;bids=297133.133&amp;type=3&amp;subid=0</impressionpixel><advertiserid>38605</advertiserid><advertisername>Kohls Department Stores Inc</advertisername><network id="1">US Network</network></link><link type="TEXT"><categories><category id="12">Department Store</category></categories><promotiontypes><promotiontype id="1">General Promotion</promotiontype></promotiontypes><offerdescription>Shop Kohl's.com today!</offerdescription><offerstartdate>2013-08-08</offerstartdate><offerenddate>2019-07-31</offerenddate><clickurl>http://click.linksynergy.com/fs-bin/click?id=V8uMkWlCTes&amp;offerid=297133.132&amp;type=3&amp;subid=0</clickurl><impressionpixel>http://ad.linksynergy.com/fs-bin/show?id=V8uMkWlCTes&amp;bids=297133.132&amp;type=3&amp;subid=0</impressionpixel><advertiserid>38605</advertiserid><advertisername>Kohls Department Stores Inc</advertisername><network id="1">US Network</network></link></couponfeed>
    XML
    stub_request(
      :get,
      "http://couponfeed.linksynergy.com/coupon?resultsperpage=3&mid=38605&network=1&token=#{token}"
      ).
      to_return(
        status: 200,
        body: xml_response,
        headers: { "Content-type" => "text/xml; charset=UTF-8" }
    )
    response = LinkshareCouponApi.coupon_web_service(resultsperpage: 3, mid: 38605, network: 1)
    assert_equal 20, response.total_matches
    assert_equal 7, response.total_pages
    assert_equal 1, response.page_number_requested
    assert_equal "Free Shipping!", response.data.first.offerdescription
    assert_equal "http://click.linksynergy.com/fs-bin/click?id=V8uMkWlCTes&offerid=297133.132&type=3&subid=0", response.data.last.clickurl
  end

  def test_coupon_web_service_all_results
     LinkshareCouponApi.token = token
    xml_response_1 = <<-XML
      <?xml version="1.0" encoding="UTF-8"?>
      <couponfeed><TotalMatches>9</TotalMatches><TotalPages>3</TotalPages><PageNumberRequested>1</PageNumberRequested><link type="TEXT"><categories><category id="1">Apparel</category><category id="20">House wares</category><category id="21">Jewelry &amp; Accessories</category></categories><promotiontypes><promotiontype id="7">Free Shipping</promotiontype></promotiontypes><offerdescription>Free Shipping!</offerdescription><offerstartdate>2013-08-30</offerstartdate><offerenddate>2013-09-09</offerenddate><couponrestriction>On Orders Over $75</couponrestriction><clickurl>http://click.linksynergy.com/fs-bin/click?id=V8uMkWlCTes&amp;offerid=297133.410&amp;type=3&amp;subid=0</clickurl><impressionpixel>http://ad.linksynergy.com/fs-bin/show?id=V8uMkWlCTes&amp;bids=297133.410&amp;type=3&amp;subid=0</impressionpixel><advertiserid>38605</advertiserid><advertisername>Kohls Department Stores Inc</advertisername><network id="1">US Network</network></link><link type="TEXT"><categories><category id="12">Department Store</category></categories><promotiontypes><promotiontype id="1">General Promotion</promotiontype></promotiontypes><offerdescription>Take an Extra 15% off your order when you use your Kohl's Charge card!</offerdescription><offerstartdate>2013-08-08</offerstartdate><offerenddate>2016-08-01</offerenddate><clickurl>http://click.linksynergy.com/fs-bin/click?id=V8uMkWlCTes&amp;offerid=297133.133&amp;type=3&amp;subid=0</clickurl><impressionpixel>http://ad.linksynergy.com/fs-bin/show?id=V8uMkWlCTes&amp;bids=297133.133&amp;type=3&amp;subid=0</impressionpixel><advertiserid>38605</advertiserid><advertisername>Kohls Department Stores Inc</advertisername><network id="1">US Network</network></link><link type="TEXT"><categories><category id="12">Department Store</category></categories><promotiontypes><promotiontype id="1">General Promotion</promotiontype></promotiontypes><offerdescription>Shop Kohl's.com today!</offerdescription><offerstartdate>2013-08-08</offerstartdate><offerenddate>2019-07-31</offerenddate><clickurl>http://click.linksynergy.com/fs-bin/click?id=V8uMkWlCTes&amp;offerid=297133.132&amp;type=3&amp;subid=0</clickurl><impressionpixel>http://ad.linksynergy.com/fs-bin/show?id=V8uMkWlCTes&amp;bids=297133.132&amp;type=3&amp;subid=0</impressionpixel><advertiserid>38605</advertiserid><advertisername>Kohls Department Stores Inc</advertisername><network id="1">US Network</network></link></couponfeed>
    XML
    xml_response_2 = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<couponfeed><TotalMatches>9</TotalMatches><TotalPages>3</TotalPages><PageNumberRequested>2</PageNumberRequested><link type="TEXT"><categories><category id="12">Department Store</category></categories><promotiontypes><promotiontype id="1">General Promotion</promotiontype></promotiontypes><offerdescription>Kohl's</offerdescription><offerstartdate>2013-08-08</offerstartdate><offerenddate>2019-12-31</offerenddate><clickurl>http://click.linksynergy.com/fs-bin/click?id=V8uMkWlCTes&amp;offerid=297133.4&amp;type=3&amp;subid=0</clickurl><impressionpixel>http://ad.linksynergy.com/fs-bin/show?id=V8uMkWlCTes&amp;bids=297133.4&amp;type=3&amp;subid=0</impressionpixel><advertiserid>38605</advertiserid><advertisername>Kohls Department Stores Inc</advertisername><network id="1">US Network</network></link><link type="TEXT"><categories><category id="12">Department Store</category></categories><promotiontypes><promotiontype id="1">General Promotion</promotiontype></promotiontypes><offerdescription>Kohls.com</offerdescription><offerstartdate>2013-08-08</offerstartdate><offerenddate>2019-12-31</offerenddate><clickurl>http://click.linksynergy.com/fs-bin/click?id=V8uMkWlCTes&amp;offerid=297133.5&amp;type=3&amp;subid=0</clickurl><impressionpixel>http://ad.linksynergy.com/fs-bin/show?id=V8uMkWlCTes&amp;bids=297133.5&amp;type=3&amp;subid=0</impressionpixel><advertiserid>38605</advertiserid><advertisername>Kohls Department Stores Inc</advertisername><network id="1">US Network</network></link><link type="TEXT"><categories><category id="12">Department Store</category></categories><promotiontypes><promotiontype id="1">General Promotion</promotiontype></promotiontypes><offerdescription>Candie's</offerdescription><offerstartdate>2013-08-08</offerstartdate><offerenddate>2019-12-31</offerenddate><clickurl>http://click.linksynergy.com/fs-bin/click?id=V8uMkWlCTes&amp;offerid=297133.6&amp;type=3&amp;subid=0</clickurl><impressionpixel>http://ad.linksynergy.com/fs-bin/show?id=V8uMkWlCTes&amp;bids=297133.6&amp;type=3&amp;subid=0</impressionpixel><advertiserid>38605</advertiserid><advertisername>Kohls Department Stores Inc</advertisername><network id="1">US Network</network></link></couponfeed>
    XML
    xml_response_3 = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<couponfeed><TotalMatches>9</TotalMatches><TotalPages>3</TotalPages><PageNumberRequested>3</PageNumberRequested><link type="TEXT"><categories><category id="12">Department Store</category></categories><promotiontypes><promotiontype id="1">General Promotion</promotiontype></promotiontypes><offerdescription>Shop Clearance at Kohls.com</offerdescription><offerstartdate>2013-08-08</offerstartdate><offerenddate>2019-12-31</offerenddate><clickurl>http://click.linksynergy.com/fs-bin/click?id=V8uMkWlCTes&amp;offerid=297133.7&amp;type=3&amp;subid=0</clickurl><impressionpixel>http://ad.linksynergy.com/fs-bin/show?id=V8uMkWlCTes&amp;bids=297133.7&amp;type=3&amp;subid=0</impressionpixel><advertiserid>38605</advertiserid><advertisername>Kohls Department Stores Inc</advertisername><network id="1">US Network</network></link><link type="TEXT"><categories><category id="12">Department Store</category></categories><promotiontypes><promotiontype id="1">General Promotion</promotiontype></promotiontypes><offerdescription>Elle</offerdescription><offerstartdate>2013-08-08</offerstartdate><offerenddate>2019-12-31</offerenddate><clickurl>http://click.linksynergy.com/fs-bin/click?id=V8uMkWlCTes&amp;offerid=297133.8&amp;type=3&amp;subid=0</clickurl><impressionpixel>http://ad.linksynergy.com/fs-bin/show?id=V8uMkWlCTes&amp;bids=297133.8&amp;type=3&amp;subid=0</impressionpixel><advertiserid>38605</advertiserid><advertisername>Kohls Department Stores Inc</advertisername><network id="1">US Network</network></link><link type="TEXT"><categories><category id="12">Department Store</category></categories><promotiontypes><promotiontype id="1">General Promotion</promotiontype></promotiontypes><offerdescription>Food Network</offerdescription><offerstartdate>2013-08-08</offerstartdate><offerenddate>2019-12-31</offerenddate><clickurl>http://click.linksynergy.com/fs-bin/click?id=V8uMkWlCTes&amp;offerid=297133.9&amp;type=3&amp;subid=0</clickurl><impressionpixel>http://ad.linksynergy.com/fs-bin/show?id=V8uMkWlCTes&amp;bids=297133.9&amp;type=3&amp;subid=0</impressionpixel><advertiserid>38605</advertiserid><advertisername>Kohls Department Stores Inc</advertisername><network id="1">US Network</network></link></couponfeed>
    XML
    stub_request(
      :get,
      "http://couponfeed.linksynergy.com/coupon?resultsperpage=3&mid=38605&network=1&token=#{token}"
      ).
      to_return(
        status: 200,
        body: xml_response_1,
        headers: { "Content-type" => "text/xml; charset=UTF-8" }
    )
    stub_request(
      :get,
      "http://couponfeed.linksynergy.com/coupon?resultsperpage=3&mid=38605&network=1&pagenumber=2&token=#{token}"
      ).
      to_return(
        status: 200,
        body: xml_response_2,
        headers: { "Content-type" => "text/xml; charset=UTF-8" }
    )
    stub_request(
      :get,
      "http://couponfeed.linksynergy.com/coupon?resultsperpage=3&mid=38605&network=1&pagenumber=3&token=#{token}"
      ).
      to_return(
        status: 200,
        body: xml_response_3,
        headers: { "Content-type" => "text/xml; charset=UTF-8" }
    )
    data = LinkshareCouponApi.coupon_web_service(resultsperpage:3, mid: 38605, network:1).all
    assert_equal 9, data.count
    assert_equal "Free Shipping!", data.first.offerdescription
    assert_equal "http://ad.linksynergy.com/fs-bin/show?id=V8uMkWlCTes&bids=297133.9&type=3&subid=0", data.last.impressionpixel
  end

  def test_coupon_web_service_with_no_options
    LinkshareCouponApi.token = token
    xml_response = <<-XML
      <?xml version="1.0" encoding="UTF-8"?>
      <couponfeed><TotalMatches>3</TotalMatches><TotalPages>1</TotalPages><PageNumberRequested>1</PageNumberRequested><link type="TEXT"><categories><category id="1">Apparel</category><category id="20">House wares</category><category id="21">Jewelry &amp; Accessories</category></categories><promotiontypes><promotiontype id="7">Free Shipping</promotiontype></promotiontypes><offerdescription>Free Shipping!</offerdescription><offerstartdate>2013-08-30</offerstartdate><offerenddate>2013-09-09</offerenddate><couponrestriction>On Orders Over $75</couponrestriction><clickurl>http://click.linksynergy.com/fs-bin/click?id=V8uMkWlCTes&amp;offerid=297133.410&amp;type=3&amp;subid=0</clickurl><impressionpixel>http://ad.linksynergy.com/fs-bin/show?id=V8uMkWlCTes&amp;bids=297133.410&amp;type=3&amp;subid=0</impressionpixel><advertiserid>38605</advertiserid><advertisername>Kohls Department Stores Inc</advertisername><network id="1">US Network</network></link><link type="TEXT"><categories><category id="12">Department Store</category></categories><promotiontypes><promotiontype id="1">General Promotion</promotiontype></promotiontypes><offerdescription>Take an Extra 15% off your order when you use your Kohl's Charge card!</offerdescription><offerstartdate>2013-08-08</offerstartdate><offerenddate>2016-08-01</offerenddate><clickurl>http://click.linksynergy.com/fs-bin/click?id=V8uMkWlCTes&amp;offerid=297133.133&amp;type=3&amp;subid=0</clickurl><impressionpixel>http://ad.linksynergy.com/fs-bin/show?id=V8uMkWlCTes&amp;bids=297133.133&amp;type=3&amp;subid=0</impressionpixel><advertiserid>38605</advertiserid><advertisername>Kohls Department Stores Inc</advertisername><network id="1">US Network</network></link><link type="TEXT"><categories><category id="12">Department Store</category></categories><promotiontypes><promotiontype id="1">General Promotion</promotiontype></promotiontypes><offerdescription>Shop Kohl's.com today!</offerdescription><offerstartdate>2013-08-08</offerstartdate><offerenddate>2019-07-31</offerenddate><clickurl>http://click.linksynergy.com/fs-bin/click?id=V8uMkWlCTes&amp;offerid=297133.132&amp;type=3&amp;subid=0</clickurl><impressionpixel>http://ad.linksynergy.com/fs-bin/show?id=V8uMkWlCTes&amp;bids=297133.132&amp;type=3&amp;subid=0</impressionpixel><advertiserid>38605</advertiserid><advertisername>Kohls Department Stores Inc</advertisername><network id="1">US Network</network></link></couponfeed>
    XML
    stub_request(
      :get,
      "http://couponfeed.linksynergy.com/coupon?token=#{token}"
      ).
      to_return(
        status: 200,
        body: xml_response,
        headers: { "Content-type" => "text/xml; charset=UTF-8" }
    )
    response = LinkshareCouponApi.coupon_web_service()
    assert_equal 3, response.total_matches
    assert_equal 1, response.total_pages
    assert_equal 1, response.page_number_requested
    assert_equal "Free Shipping!", response.data.first.offerdescription
    assert_equal 'http://click.linksynergy.com/fs-bin/click?id=V8uMkWlCTes&offerid=297133.132&type=3&subid=0', response.data.last.clickurl
  end

  def test_coupon_web_service_with_multiple_options_for_one_option
    LinkshareCouponApi.token = token
    options = { category: '1|20|21', mid: 38650, network: 1 }
    xml_response = <<-XML
      <?xml version="1.0" encoding="UTF-8"?>
      <couponfeed><TotalMatches>1</TotalMatches><TotalPages>1</TotalPages><PageNumberRequested>1</PageNumberRequested><link type="TEXT"><categories><category id="1">Apparel</category><category id="20">House wares</category><category id="21">Jewelry &amp; Accessories</category></categories><promotiontypes><promotiontype id="7">Free Shipping</promotiontype></promotiontypes><offerdescription>Free Shipping!</offerdescription><offerstartdate>2013-08-30</offerstartdate><offerenddate>2013-09-09</offerenddate><couponrestriction>On Orders Over $75</couponrestriction><clickurl>http://click.linksynergy.com/fs-bin/click?id=V8uMkWlCTes&amp;offerid=297133.410&amp;type=3&amp;subid=0</clickurl><impressionpixel>http://ad.linksynergy.com/fs-bin/show?id=V8uMkWlCTes&amp;bids=297133.410&amp;type=3&amp;subid=0</impressionpixel><advertiserid>38605</advertiserid><advertisername>Kohls Department Stores Inc</advertisername><network id="1">US Network</network></link></couponfeed>
    XML
    stub_request(
      :get,
      "http://couponfeed.linksynergy.com/coupon?category=1%7C20%7C21&mid=38650&network=1&token=#{token}"
      ).
      to_return(
        status: 200,
        body: xml_response,
        headers: { "Content-type" => "text/xml; charset=UTF-8" }
    )
    response = LinkshareCouponApi.coupon_web_service(options)
    assert_equal 1, response.total_matches
    assert_equal 1, response.total_pages
    assert_equal 1, response.page_number_requested
    assert_equal "Free Shipping!", response.data.first.offerdescription
    assert_equal 'http://click.linksynergy.com/fs-bin/click?id=V8uMkWlCTes&offerid=297133.410&type=3&subid=0', response.data.last.clickurl
  end

  private

  def token
    "abcdef"
  end
end
