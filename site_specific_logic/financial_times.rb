def financial_times_fetch_headline(url)
  doc = Nokogiri::HTML(open(url))
  # doc = Nokogiri::HTML(open('http://www.economist.com/news/leaders/21633813-it-closer-crisis-west-or-vladimir-putin-realise-wounded-economy'))
  h2 = doc.css('h2.fly-title').text
  puts h2
  h3 = doc.css('h3.headline').text
  puts h3
  raw_headline = h2 + " " + h3
  raw_headline
  
end