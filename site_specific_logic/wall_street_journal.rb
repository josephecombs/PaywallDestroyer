def wall_street_journal_fetch_headline(url)
  doc = Nokogiri::HTML(open(url))
  # doc = Nokogiri::HTML(open('http://www.economist.com/news/leaders/21633813-it-closer-crisis-west-or-vladimir-putin-realise-wounded-economy'))
  h1 = doc.css('h1.wsj-article-headline')
  h2 = doc.css('h2.sub-head')
  
  #I think this is for just blogs
  h3 = doc.css('h3.post-title').text

  raw_headline = h1 + " " + h2 + " " + h3 + " WSJ"
  raw_headline
end