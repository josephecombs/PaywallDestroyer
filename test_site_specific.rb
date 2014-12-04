require 'nokogiri'
require 'open-uri'

def financial_times_fetch_headline
  # doc = Nokogiri::HTML(open(url))
  doc = Nokogiri::HTML(open('http://www.ft.com/intl/cms/s/2/d41596a6-76ea-11e4-8273-00144feabdc0.html'))
  h1 = doc.css('.syndicationHeadline > h1').text
  author = doc.css('.byline').text
  raw_headline = h1 + " " + author
  raw_headline
end

puts financial_times_fetch_headline