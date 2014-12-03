require 'rubygems'
require 'oauth'
require 'json'
require 'open-uri'
require 'nokogiri'
require 'tweetstream'
Dir["/site_specific_logic/*.rb"].each {|file| require file }

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

def bust_paywall(status, publication_arr)
  puts "analyzed one tweet"
  puts status.text
  #turn this back on in production later when you add more media entities
  if status.user.screen_name.downcase == publication_arr[1]
    puts "analyzed one economist tweet"
    # raw_text = economist_fetch_headline(status.urls[0].attrs[:expanded_url])
    raw_text = send((publication_arr[2].to_s + '_fetch_headline').to_sym, status.urls[0].attrs[:expanded_url])

    #google queryify the headline
    url = google_headlineify(raw_text)
  
    consumer_key = OAuth::Consumer.new(KEYS[:consumer_key_string], KEYS[:consumer_secret_string])
    access_token = OAuth::Token.new(KEYS[:access_token_string], KEYS[:access_secret_string])
    handle = "@" + status.user.screen_name
    #respond to tweet with link to google results only if a useful headline is found
    unless (url ==  "https://www.google.com/#q=")
      send_response_tweet(status.id, handle, url, consumer_key, access_token)
    end
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

# def economist_fetch_headline(url)
#   #this method accepts a url of a news article and returns text
#   doc = Nokogiri::HTML(open(url))
#   # doc = Nokogiri::HTML(open('http://www.economist.com/news/leaders/21633813-it-closer-crisis-west-or-vladimir-putin-realise-wounded-economy'))
#   h2 = doc.css('h2.fly-title').text
#   puts h2
#   h3 = doc.css('h3.headline').text
#   puts h3
#   raw_headline = h2 + " " + h3
#   raw_headline
# end

client = TweetStream::Client.new

#keys must be named according to convention - economist -> economist_fetch_headline; financial_times -> financial_times_fetch_headline
ARGS_MAP = {
  me: [24480915, 'josephcombs', :me],
  economist: [5988062, 'theeconomist', :economist],
  financial_times: [18949452, 'FT', :financial_times]
}

puts (ARGS_MAP[:me])
puts (ARGV[0].to_sym)
puts (ARGS_MAP[ARGV[0].to_sym])

client.follow(ARGS_MAP[ARGV[0][0].to_sym]) do |status|
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

  bust_paywall(status, ARGS_MAP[ARGV[0]])
  # puts "hi joe!"
  # puts ARGV[0]
end

