require 'open-uri'
require 'nokogiri'
require 'mechanize'

class Bird < ActiveRecord::Base
  def self.search(post)
    url = "https://twitter.com/search?vertical=default&q=#{post}&src=typd&lang=ja"
    charset = nil
    html = open(url) do |f|
      charset = f.charset
      f.read
    end

    doc = Nokogiri::HTML.parse(html, nil, charset)
    tweets_list = []
    doc.xpath("//ol[@id='stream-items-id']/li/div/div[2]/div/p").each do |tweet|
      tweets_list << tweet.inner_text
    end
    tweets_list[rand(tweets_list.size)]
  end
end
