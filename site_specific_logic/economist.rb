def economist_fetch_headline(url)
  #this method visits an economist.com url and returns the headline and subheadline of the story 
  doc = Nokogiri::HTML(open(url))
  h2 = doc.css('fly-title').text
  h3 = doc.css('h3.headline').text
  raw_headline = h2 + " " + h3
  raw_headline
end
