require 'rubygems'
require 'oauth'
require 'json'
require 'open-uri'
require 'nokogiri'

def get_credentials(filename)
  temp_arr = []
  i = 0
  #get your own keys if you are going to use this --> apps.twitter.com
  File.readlines(filename).each do |line, idx|
    temp_arr[i] = line.gsub!("\n","")
    i += 1
  end
  
  keys = {
    consumer_key_string: temp_arr[0],
    consumer_secret_string: temp_arr[1],
    access_token_string: temp_arr[2],
    access_secret_string: temp_arr[3],
    google_api_key: temp_arr[4]
  }
  
  keys
end


def get_new_tweets(target_user, consumer_key, access_token)
  baseurl = "https://api.twitter.com"
  path    = "/1.1/statuses/show.json"
  query   = URI.encode_www_form("screen_name" => target_user)
  address = URI("#{baseurl}#{path}?#{query}")
  request = Net::HTTP::Get.new address.request_uri

  # Set up HTTP.
  http             = Net::HTTP.new address.host, address.port
  http.use_ssl     = true
  http.verify_mode = OpenSSL::SSL::VERIFY_PEER

  # Issue the request.
  request.oauth! http, consumer_key, access_token
  http.start
  response = http.request request
  
end

# def get_top_google_link(headline, google_api_key)
#   url = google_headlineify(headline, google_api_key)
#   # doc = JSON.parse(open(url))
#   # puts doc
#   # sleep 100
#
#   address = URI(url)
#   request = Net::HTTP::Get.new address.request_uri
#   http = Net::HTTP.new address.host, address.port
#
#   http.start
#   response = http.request(request)
#   results = JSON.parse(response.body)
#
#   puts results
#   # top_search_result = doc.css('li.card-section')
#   # puts top_search_result
# #https://www.google.com/#q=Russia+A+wounded+economy+It+is+closer+to+crisis+than+the+West+or+Vladimir+Putin+realized
# end

def google_headlineify(text)
  words_arr = text.split(" ")
  # doing it this way is basically too complicated.  Users will have to click top link
  # url = "http://ajax.googleapis.com/ajax/services/search/web?v=1.0&key=AIzaSyCRLjxxwTkiHqYBVSp8LBrs31q9mcxzAGc&q="
  url = "https://www.google.com/#q="
  words_arr.each_with_index do |word, idx|
    if idx == 0
      url += "#{word}"
    else
      url += "+#{word}"
    end
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

KEYS = get_credentials('keys.txt')

target_user="@theeconomist"
consumer_key = OAuth::Consumer.new(KEYS[:consumer_key_string], KEYS[:consumer_secret_string])
access_token = OAuth::Token.new(KEYS[:access_token_string], KEYS[:access_secret_string])


query = google_headlineify("Russia A Wounded economy")
send_response_tweet("536245096811745280", "@josephcombs", query, consumer_key, access_token)
