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

client = TweetStream::Client.new

client.follow(24480915) do |status|
  puts status.text
  puts "========================"
  puts status.id
  puts "========================"
  puts status.urls
  puts "========================"
  p status.urls
  puts "========================"
  puts status.user_mentions[0].attrs[:screen_name]
  #####CORRECT !!!######
  puts status.urls[0].attrs[:expanded_url]
  # p status.urls.attrs[:url]
  puts "========================"
  puts status.urls.attrs[:url]

  # puts status[:entities][:urls][:expanded_url]
  
  bust_paywall(status)
end

def bust_paywall(status)
  
  #follow the link in the tweet
  
  #get the headline
  
  #google queryify the headline
  
  #respond to tweet with 
end