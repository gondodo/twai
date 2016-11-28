require 'open-uri'
require 'nokogiri'
require 'mechanize'
require 'twitter'

class Bird < ActiveRecord::Base
  def self.search(post)
    client = Twitter::REST::Client.new do |config|
      config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
    end

    since_id = nil
    post = "乃木坂って知ってる？"
    # count : 取得する件数
    # result_type : 内容指定。recentで最近の内容、popularで人気の内容。
    # exclude : 除外する内容。retweetsでリツイートを除外。
    # since_id : 指定ID以降から検索だが、検索結果が100件以上の場合は無効。
    result_tweets = client.search(post, count: 1, result_type: "popular", exclude: "retweets", since_id: since_id, locale: "ja", lang: "ja")
    reply = []
    result_tweets.each_with_index do |tw|
      reply << tw.full_text
    end
    if reply.present?
      reply[0]
    else
      "ごめん、わからんわ"
    end
  end
end
