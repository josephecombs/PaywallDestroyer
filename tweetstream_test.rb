require 'mechanize'
require 'rubygems'
require 'oauth'
require 'json'
require 'open-uri'
require 'nokogiri'
require 'tweetstream'
require 'require_all'
require_all 'site_specific_logic'
# require_relative 'site_specific_logic/me.rb'

def get_credentials(filename)
  #get your own keys if you are going to use this --> apps.twitter.com
  temp_arr = []
  i = 0
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

def bust_paywall(status, publication_hash)  
  puts "analyzed one tweet"
  puts status.text
  puts publication_hash[:twitter_screen_name].downcase
  puts status.user.screen_name.downcase
  # turn this back on in production later when you add more media entities
  if status.user.screen_name.downcase == publication_hash[:twitter_screen_name].downcase
    puts "made it inside this conditional"
    puts publication_hash[:convention_placeholder].to_s + '_fetch_headline'
    puts "first url: " + status.urls[0].attrs[:expanded_url]
    raw_text = send((publication_hash[:convention_placeholder].to_s + '_fetch_headline').to_sym, status.urls[0].attrs[:expanded_url])

    #google queryify the headline
    url = google_headlineify(raw_text)
    
    #oauth junk
    consumer_key = OAuth::Consumer.new(KEYS[:consumer_key_string], KEYS[:consumer_secret_string])
    access_token = OAuth::Token.new(KEYS[:access_token_string], KEYS[:access_secret_string])
    handle = "@" + status.user.screen_name
    #respond to tweet with link to google results only if a useful headline is found
    
    puts "url: " + url
    
    unless (url ==  "https://www.google.com/#q=")
      send_response_tweet(status.id, handle, url, consumer_key, access_token)
      # puts "this is where I would post a tweet"
    end
    
    puts "analyzed one #{handle} tweet"
  end
end

def google_headlineify(text)
  #this method takes in text and constructs the appropriate google url to visit to find the origin article
  words_arr = text.split(" ")
  url = "https://www.google.com/#q="
  words_arr.each_with_index do |word, idx|
    temp_word = word.gsub(/[^a-zA-Z0-9 ]/,"")
    if idx == 0
      url += "#{temp_word}"
    else
      url += "+#{temp_word}"
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

client = TweetStream::Client.new

#keys must be named according to convention - economist -> economist_fetch_headline; financial_times -> financial_times_fetch_headline.  convention broken after 12/7 changes
ARGS_MAP = {
  josephcombs: { twitter_id: 24480915, twitter_screen_name: 'josephcombs', convention_placeholder: :me },
  TheEconomist: { twitter_id: 5988062, twitter_screen_name: 'theeconomist', convention_placeholder: :economist },
  FT: { twitter_id: 18949452, twitter_screen_name: 'FT', convention_placeholder: :financial_times },
  WSJ: { twitter_id: 3108351, twitter_screen_name: 'WSJ', convention_placeholder: :wall_street_journal },
  nytimes: { twitter_id: 807095, twitter_screen_name: 'nytimes', convention_placeholder: :new_york_times }
}

client.follow(5988062, 18949452, 807095) do |status|
# client.follow(5988062, 18949452, 3108351, 807095) do |status|
# client.follow((ARGS_MAP[ARGV[0].to_sym])[:twitter_id], ARGS_MAP[ARGV[1].to_sym])[:twitter_id]) do |status|
  # puts "following a lot"
  # puts status.text
  # puts status.methods - "aaa".methods
  # puts status.user
  # puts status.user.methods - "aaa".methods
  # puts status.user.screen_name
  puts status.user.screen_name
  if ARGS_MAP.has_key?(status.user.screen_name.to_sym)
    puts status.user.screen_name
    bust_paywall(status, ARGS_MAP[status.user.screen_name.to_sym]) 
  end
end
