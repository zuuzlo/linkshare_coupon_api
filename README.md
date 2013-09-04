# LinkshareCouponApi

Ruby wrapper for [LinkShare Coupon Web Services](http://helpcenter.linkshare.com/publisher/questions.php?questionid=865)Followed general logic found in linkshare_api gem

If you need services that are not yet supported, feel free to [contribute](#contributing).
For questions or bugs please [create an issue](../../issues/new).

## Installation

Add this line to your application's Gemfile:

    gem 'linkshare_coupon_api'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install linkshare_coupon_api

## Usage

### Coupon Web Services

Easy access to coupons and promotional link data for your advertisers using [Coupon Web Service](http://helpcenter.linkshare.com/publisher/questions.php?questionid=865)

```ruby
#Search for promotion type: "Clearance" from Wal-Mart, within category  Apparel - Babies & Kids
#in the US network
options = {
  promotiontype: 3 #3 - Clearance,
  mid: 2149, # Wal-Mart
  category: 3, # Apparel - Babies & Kids
  network: 1 # 1 - US,
  resultsperpage: 500 # max per page number between 1 and 500
}
response = LinkshareAPI.coupon_web_service(options)
response.data.each do |link|
  puts "Offer Description: #{link.offerdescription}"
  puts "Category: #{link.categories.category}"
end
```

If there are multiple pages, you can retrieve all pages by using the ```all``` method, as follows:

```ruby
  response.all.each do |link|
    #do stuff
  end
```

#Submitting Queries with Multiple Values
You can place multiple values in all query string variables, except for 'token=', by delimiting the values with a pipe character '|'. Multiple values passed within one variable are treated as an OR condition. For example, 'category=1|2|3' sends links from categories 1 or 2 or 3.
```ruby
options = {
  category: '3|12|20', # 3-Apparel - Men  12-Deparment Store 20-Housewares
  network: 1 # 1 - US,
}
response = LinkshareAPI.coupon_web_service(options)
response.data.each do |item|
  # Do stuff
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
