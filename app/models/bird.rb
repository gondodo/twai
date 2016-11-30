require 'open-uri'
require 'nokogiri'
require 'mechanize'

class Bird < ActiveRecord::Base
  def self.search(post)
    url = URI.parse("https://twitter.com/search?")
    charset = nil
    url.query = {
      vertical: "default",
      q: post,
      src:"typd",
      lang: "ja"
    }.to_param

    charset = nil
    html = open(url) do |f|
      charset = f.charset # 文字種別を取得
      f.read # htmlを読み込んで変数htmlに渡す
    end

    # htmlをパース(解析)してオブジェクトを生成
    doc = Nokogiri::HTML.parse(html, nil, charset)

    tweets_list = []
    doc.xpath("//ol[@id='stream-items-id']/li/div/div[2]/div/p").each do |tweet|
      tweets_list << tweet.inner_text
    end
    if tweets_list.present?
      tweets_list[rand(tweets_list.size)]
    else
      "せやなー、知らんけどｗ"
    end
  end
end
