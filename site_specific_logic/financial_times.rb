def financial_times_fetch_headline(url)
  doc = Nokogiri::HTML(open(url))
  # doc = Nokogiri::HTML(open('http://www.economist.com/news/leaders/21633813-it-closer-crisis-west-or-vladimir-putin-realise-wounded-economy'))
  h1 = doc.css('.syndicationHeadline > h1').text
  author = doc.css('.byline').text
  raw_headline = h1 + " " + author
  raw_headline
end