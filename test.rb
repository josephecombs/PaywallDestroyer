require 'rubygems'
require 'oauth'
require 'json'
require 'open-uri'
require 'nokogiri'

def get_credentials
  temp_arr = []
  i = 0
  #get your own keys if you are going to use this --> apps.twitter.com
  File.readlines('keys.txt').each do |line, idx|
    temp_arr[i] = line.gsub!("\n","")
    i += 1
  end
  
  keys = {
    consumer_key_string: temp_arr[0],
    consumer_secret_string: temp_arr[1],
    access_token_string: temp_arr[2],
    access_secret_string: temp_arr[3]
  }
  
  keys
end


def get_new_tweets(target_user, consumer_key, access_token)
  
end

def get_google_link(headline)
#https://www.google.com/#q=Russia+A+wounded+economy+It+is+closer+to+crisis+than+the+West+or+Vladimir+Putin+realized
end

def google_headlineify(text)
  words_arr = text.split(" ")
  url = "http://www.google.com/#q="
  words_arr.each do |word|
    url += "+#{word}"
  end  
  url
end

def send_response_tweet(tweet_id, user, google_link, consumer_key, access_token)
  baseurl = "https://api.twitter.com"
  path    = "/1.1/statuses/update.json"
  address = URI("#{baseurl}#{path}")
  request = Net::HTTP::Post.new address.request_uri
  request.set_form_data(
    status: "helpful link for #{user} readers: #{google_link}",
    in_reply_to_status_id: tweet_id
  )

  # Set up HTTP.
  http             = Net::HTTP.new address.host, address.port
  http.use_ssl     = true
  http.verify_mode = OpenSSL::SSL::VERIFY_PEER

  # Issue the request.
  request.oauth! http, consumer_key, access_token
  http.start
  response = http.request request
end

KEYS = get_credentials

consumer_key = OAuth::Consumer.new(KEYS[:consumer_key_string], KEYS[:consumer_secret_string])
access_token = OAuth::Token.new(KEYS[:access_token_string], KEYS[:access_secret_string])

puts google_headlineify("Just a test news article headline")

#send_response_tweet("536245096811745280", "@josephcombs", "test-google-linKK.com", consumer_key, access_token)
