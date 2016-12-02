require 'open-uri'
require 'nokogiri'
require 'mechanize'

class Bird < ActiveRecord::Base
  def self.search(post)
    # クエリするURLを生成
    url = Bird.create_url(post)
    # htmlをパース(解析)してオブジェクトを生成
    doc = Bird.open_url(url)

    tweets_list = []
    logger.info("取得したツイート数": doc.xpath("//ol[@id='stream-items-id']/li/div/div[2]").size)
    doc.xpath("//ol[@id='stream-items-id']/li/div/div[2]").each do |tweet|
      tweet_hash = {
        account: tweet.xpath("div/a/span[2]").inner_text,
        tweet: tweet.xpath("div/p").inner_text
      }
      tweets_list << tweet_hash
    end
    logger.info(tweets_list)

    if tweets_list.present?
      reply = tweets_list[rand(tweets_list.size)]
    else
      reply = {
        account: "なし",
        tweet: "せやなー、知らんけどｗ"
      }
    end
    bird = Bird.create(account: reply[:account], tweet:reply[:tweet] , post: post)
    bird.tweet
  end

  private
    def self.create_url(post)
      url = URI.parse("https://twitter.com/search?")
      charset = nil
      url.query = {
        vertical: "default",
        q: post,
        src:"typd",
        lang: "ja"
      }.to_param
      url
    end

    def self.open_url(url)
      charset = nil
      html = open(url) do |f|
        charset = f.charset # 文字種別を取得
        f.read # htmlを読み込んで変数htmlに渡す
      end
      doc = Nokogiri::HTML.parse(html, nil, charset)
    end
end
