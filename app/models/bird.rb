require 'open-uri'
require 'nokogiri'
require 'mechanize'
require 'twitter'

class Bird < ActiveRecord::Base
  client = Twitter::REST::Client.new do |config|
    config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
    config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
    config.access_token = ENV['TWITTER_ACCESS_TOKEN']
    config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
  end

  def self.search(post)
    url = "https://twitter.com/search?vertical=default&q=#{post}&src=typd&lang=ja"
    opt = {}
    opt['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/XXXXXXXXXXXXX Safari/XXXXXX Vivaldi/XXXXXXXXXX'
    charset = nil
    html = open(url, opt) do |f|
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
