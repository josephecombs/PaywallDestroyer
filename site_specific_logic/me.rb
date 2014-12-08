# test: http://nyti.ms/1sasoeL

def me_fetch_headline(url)
  puts "inside site-specific logic"
  # doc = Nokogiri::HTML(open(url))
  # doc = Nokogiri::HTML(open('http://www.economist.com/news/leaders/21633813-it-closer-crisis-west-or-vladimir-putin-realise-wounded-economy'))
  agent = Mechanize.new
  agent.user_agent_alias = 'Mac Safari'
  page = agent.get(url)
  h1 = page.search('h1.wsj-article-headline').text
  h2 = page.search('h2.sub-head')
  #I think this is just for blogs:
  h3 = page.search('h3.post-title')
  raw_headline = h1 + " " + h2 + " " + h3 + " NYT"
  puts raw_headline
  raw_headline
end
