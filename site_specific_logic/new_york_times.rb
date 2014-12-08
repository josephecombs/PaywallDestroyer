def new_york_times_fetch_headline(url)
  doc = Nokogiri::HTML(open(url))
  # doc = Nokogiri::HTML(open('http://www.economist.com/news/leaders/21633813-it-closer-crisis-west-or-vladimir-putin-realise-wounded-economy'))
  h2 = doc.css('h2.story-heading').text
  h1 = doc.css('h1.deck').text
  raw_headline = h2 + " " + h1 + " NYT"
  raw_headline
end