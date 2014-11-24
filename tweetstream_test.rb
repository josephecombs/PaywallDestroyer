require 'rubygems'
require 'oauth'
require 'json'
require 'open-uri'
require 'nokogiri'
require 'tweetstream'


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

KEYS = get_credentials('keys.txt')

TweetStream.configure do |config|
  config.consumer_key       = KEYS[:consumer_key_string]
  config.consumer_secret    = KEYS[:consumer_secret_string]
  config.oauth_token        = KEYS[:access_token_string]
  config.oauth_token_secret = KEYS[:access_secret_string]
  config.auth_method        = :oauth
end

def bust_paywall(status)
  puts "analyzed one tweet"
  #turn this back on in production later when you add more media entities
  if status.user.screen_name.downcase == 'theeconomist'
    raw_text = economist_fetch_headline(status.urls[0].attrs[:expanded_url])
    # raw_text = "test tweet headline"
  
    #google queryify the headline
    url = google_headlineify(raw_text)
  
    consumer_key = OAuth::Consumer.new(KEYS[:consumer_key_string], KEYS[:consumer_secret_string])
    access_token = OAuth::Token.new(KEYS[:access_token_string], KEYS[:access_secret_string])
    handle = "@" + status.user.screen_name
    #respond to tweet with link to google results

    send_response_tweet(status.id, handle, url, consumer_key, access_token)
  end
end

def google_headlineify(text)
  words_arr = text.split(" ")
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
    status: "#{user} readers, click here if paywalled: #{google_link}",
    in_reply_to_status_id: tweet_id
  )

  # Set up HTTP.
  http             = Net::HTTP.new address.host, address.port
  http.use_ssl     = true
  http.verify_mode = OpenSSL::SSL::VERIFY_PEER

  # Issue the request.
  request.oauth! http, consumer_key, access_token
  http.start
  response = http.request(request)
end

# def economist_fetch_headline()
def economist_fetch_headline(url)
  puts url
  doc = Nokogiri::HTML(open(url))
  # doc = Nokogiri::HTML(open('http://www.economist.com/news/leaders/21633813-it-closer-crisis-west-or-vladimir-putin-realise-wounded-economy'))
  h2 = doc.css('h2.fly-title').text
  puts h2
  h3 = doc.css('h3.headline').text
  puts h3
  raw_headline = h2 + " " + h3
  raw_headline
end

client = TweetStream::Client.new

#me = 24480915
#economist = 5988062

client.follow(24480915) do |status|
  # puts (status.methods - Array.methods)
  # puts "========================"
  # # ##DEPRECATED METHOD##
  # # puts status.user[:screen_name]
  # # ##NEW METHOD##
  # puts "new way hopefully works:"
  # puts status.user.screen_name
  # puts "========================"
  # puts status.text
  # puts "========================"
  # puts status.id
  # puts "========================"
  # puts status.urls
  # # puts "========================"
  # # p status.urls
  # puts "========================"
  #####CORRECT !!! - gets the url from the tweet######
  # puts status.urls[0].attrs[:expanded_url]
  # # p status.urls.attrs[:url]
  # puts "========================"
  #
  # # puts status[:entities][:urls][:expanded_url]

  bust_paywall(status)
end

