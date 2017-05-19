require 'open-uri'
require 'nokogiri'
require 'mechanize'
require 'capybara/poltergeist'

class Tabelog < ActiveRecord::Base
  belongs_to :Gourmet

  def self.scrape(gourmet)
    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, {:js_errors => false, :timeout => 10000 })
        # Capybara::Poltergeist::Driver.new(app, inspector: 'google-chrome-stable')
      # Capybara::Poltergeist::Driver.new(app,:js_errors => false, :inspector => true)
    end
    Capybara.javascript_driver = :poltergeist
    # Capybara.javascript_driver = :poltergeist_debug
    session = Capybara::Session.new(:poltergeist)
    # session.driver.headers = { "lang" => "en" }
    session.driver.headers = { 'Accept-Language' => 'ja' }
    session.visit "https://tabelog.com/"

    # 駅名指定
    logger.info("駅名指定")
    station_input = session.find('input#sa')
    station_input.native.send_key("#{gourmet.station_name}駅")
    sleep 2

    # ジャンル指定
    logger.info("ジャンル指定")
    genre_input = session.find('input#sk')
    genre_input.native.send_key(gourmet.genre)
    # session.save_screenshot
    sleep 2

    # 画面遷移
    logger.info("画面遷移")
    submit = session.find('#js-global-search-btn')
    submit.trigger('click')

    # コスト選択
    value = cost_calculate(gourmet.cost)
    # session.driver.debug

    until session.has_css?('#lstcost-sidebar') do
      logger.info("#lstcost-sidebar 探索中")
    end
    session.find('#lstcost-sidebar').find(:xpath, "option[#{value}]").select_option

    until session.has_css?('#column-side') do
      sleep 2
      logger.info("#column-side 探索中")
    end
    sidebar_btn = session.find(:xpath, '//*[@id="column-side"]/form/div[2]/div[3]/button')
    sidebar_btn.trigger('click')

    # ランキング画面遷移
    logger.info("ランキング画面遷移")
    until session.has_link?("ランキング") do
      logger.info("ランキングリンク探索")
    end
    session.click_link("ランキング")

    sleep 2
    @tabelog_list = []
    doc = open_url(session.current_url)
    doc.xpath('//*[@id="column-main"]/ul/li/div[2]').each do |node|

      @tabelog = gourmet.Tabelog.build

      header = node.xpath("div[@class='list-rst__header']/div/div/div/a")
      rst_body = node.xpath("div[contains(@class,'list-rst__body')]")
      content = rst_body.xpath("div[@class='list-rst__contents']")
      photo = rst_body.xpath("div[@class='list-rst__rst-photo js-rst-image-wrap']")

      # header
      @tabelog.rst_name = header.text
      @tabelog.url = header.attribute("href").value

      # body
      logger.info("name: #{header.text}  text: #{content.xpath("div/div[@class='list-rst__comment']/a/strong").text}")
      @tabelog.text = content.xpath("div/div[@class='list-rst__comment']/a/strong").text
      @tabelog.hoshi = content.xpath("div/div[@class='list-rst__rate']/p/span").text.to_f
      @tabelog.img_url = photo.xpath("div/p/a/img").attribute('data-original').value.insert(8, "s.")
      @tabelog.save
    end
    gourmet.Tabelog.limit(5)
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
