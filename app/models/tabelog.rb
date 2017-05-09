require 'open-uri'
require 'nokogiri'
require 'mechanize'
require 'capybara/poltergeist'

class Tabelog < ActiveRecord::Base
  belongs_to :Gourmet

  def self.scrape(gourmet)
    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, {:js_errors => false, :timeout => 5000 })
    end

    session = Capybara::Session.new(:poltergeist)
    session.visit "https://tabelog.com/"

    # ジャンル指定
    logger.info("ジャンル指定")
    genre_input = session.find('input#sk')
    genre_input.native.send_key(gourmet.genre)

    # 駅名指定
    logger.info("駅名指定")
    station_input = session.find('input#sa')
    station_input.native.send_key("#{gourmet.station_name}駅")
    sleep 2
    # 画面遷移
    logger.info("画面遷移")
    submit = session.find('#js-global-search-btn')
    submit.trigger('click')

    # ランキング画面遷移
    logger.info("ランキング画面遷移")
    sleep 2
    rank_click = session.find('a.navi-rstlst__link.navi-rstlst__link--rank', wait: 50)
    rank_click.trigger('click')

    # コスト選択
    value = cost_calculate(gourmet.cost)
    session.find('#lstcost-sidebar', wait:50).find(:xpath, "option[#{value}]").select_option
    sidebar_btn = session.find(:xpath, '//*[@id="column-side"]/form/div[2]/div[3]/button')
    sidebar_btn.trigger('click')

    # session.find(:xpath, '' )

    # test
    doc = open_url(session.current_url)
    doc.xpath('//*[@id="column-main"]/ul/li').each do |node|
      node.xpath('//a[@class="list-rst__rst-name-target cpy-rst-name"]').each do |node2|
        @tabelog = gourmet.Tabelog.build
        @tabelog.rst_name = node2.text
        @tabelog.url = node2.attribute('href').value
      end
    end
    @tabelog.save
    gourmet.Tabelog.first.url
    # bird = Bird.create(account: reply[:account], tweet:reply[:tweet] , post: post)
    # bird.tweet
  end

  private
    def self.open_url(url)
      charset = nil
      html = open(url) do |f|
        charset = f.charset # 文字種別を取得
        f.read # htmlを読み込んで変数htmlに渡す
      end
      doc = Nokogiri::HTML.parse(html, nil, charset)
    end

    def self.cost_calculate(cost)
      case cost
      when (1..1000)
        2
      when (1001..2000)
        3
      when (2001..3000)
        4
      when (3001..4000)
        5
      when (4001..5000)
        6
      when (5001..6000)
        7
      when (6001..8000)
        8
      when (8001..10000)
        9
      when (10001..15000)
        10
      when (15001..20000)
        11
      when (20001..30000)
        12
      else
        1
      end
    end
end