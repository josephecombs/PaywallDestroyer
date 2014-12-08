# test: http://www.wsj.com/articles/in-china-developer-has-new-theme-parks-1417997192?mod=e2tw

def wall_street_journal_fetch_headline(url)
  
  #TODO: WSJ IS KEEPING ME OUT!!!:
  # [30] pry(main)> a.user_agent_alias = 'Mac Safari'
  # => "Mac Safari"
  # [31] pry(main)> page = a.get("http://www.wsj.com/articles/in-china-developer-has-new-theme-parks-1417997192?mod=e2tw")
  # => #<Mechanize::Page
  #  {url #<URI::HTTP:0x007fca54f526e0 URL:http://www.wsj.com/articles/in-china-developer-has-new-theme-parks-1417997192?mod=e2tw>}
  #  {meta_refresh
  #   #<Mechanize::Page::MetaRefresh
  #    ""
  #    "/distil_r_captcha.html?Ref=/articles/in-china-developer-has-new-theme-parks-1417997192?mod=e2tw&distil_RID=AD5203A2-7EAF-11E4-8F1F-C900160ECEF6&distil_TID=20141208075612">}
  #  {title nil}
  #  {iframes}
  #  {frames}
  #  {links}
  #  {forms}>
  agent = Mechanize.new
  agent.user_agent_alias = 'Mac Safari'
  page = agent.get(url)
  h1 = page.search('h1.wsj-article-headline').text
  h2 = page.search('h2.sub-head')
  #I think this is just for blogs:
  h3 = page.search('h3.post-title')
  raw_headline = h1 + " " + h2 + " " + h3 + " NYT"
  raw_headline
end