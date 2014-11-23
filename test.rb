require 'rubygems'
require 'oauth'
require 'json'
require 'open-uri'

# globals, TODO upcase variable names later
require 'rubygems'
require 'oauth'
require 'json'

consumer_key_string = 'HPXnPN7CkMy4Rx68QXKhuvU7d'
consumer_secret_string = 'HOeaqCB5HC9W7crD1lrMkS0s00oLx7KYLqDvdUCqPj8wNQGqxW'

access_token_string = '24480915-27KxpwZIIi3z6ZAQ6g0g0qofNpC1AAW6eKRrsh4Jg'
access_secret_string = 'HypI7HSEs7BjfeiN3JBHZMv14ff3UoRGZgfOoZiliVnMx'


# You will need to set your application type to
# read/write on dev.twitter.com and regenerate your access
# token.  Enter the new values here:
consumer_key = OAuth::Consumer.new(consumer_key_string, consumer_secret_string)
access_token = OAuth::Token.new(access_token_string, access_secret_string)

# Note that the type of request has changed to POST.
# The request parameters have also moved to the body
# of the request instead of being put in the URL.
baseurl = "https://api.twitter.com"
path    = "/1.1/statuses/update.json"
address = URI("#{baseurl}#{path}")
request = Net::HTTP::Post.new address.request_uri
request.set_form_data(
  "status" => "just setting up my twttr bot, again",
)

# Set up HTTP.
http             = Net::HTTP.new address.host, address.port
http.use_ssl     = true
http.verify_mode = OpenSSL::SSL::VERIFY_PEER

# Issue the request.
request.oauth! http, consumer_key, access_token
http.start
response = http.request request

# Parse and print the Tweet if the response code was 200
tweet = nil
if response.code == '200' then
  tweet = JSON.parse(response.body)
  puts "Successfully sent #{tweet["text"]}"
else
  puts "Could not send the Tweet! " +
  "Code:#{response.code} Body:#{response.body}"
end
