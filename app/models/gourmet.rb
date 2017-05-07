class Gourmet < ActiveRecord::Base

  SEARCH_STATUS = [
  "駅名検索",
  "駅名重複あり",
  "ジャンル検索",
  "予算検索",
  "設定完了",
] #追加時は順序変更しないこと！

    def self.search(post)
      # 最初の問い
      if post == "グルメ検索"
        @keyword = create(status: SEARCH_STATUS.index("駅名検索"))
        return "駅名はー？"
      end
      case @keyword.status
        # 駅名検索
      when SEARCH_STATUS.index("駅名検索").to_s
        message = station_search(post)
        # 駅名重複
      when SEARCH_STATUS.index("駅名重複あり").to_s
        message = chofuku_station_search(post)
        # ジャンル
      when SEARCH_STATUS.index("ジャンル検索").to_s
        message = genre_search(post)
        # 予算上限
      when SEARCH_STATUS.index("予算検索").to_s
        @keyword.cost = post.to_i
        set_status("設定完了")
        @keyword
      end
      @keyword.save
      Tabelog.scrape(@keyword) if @keyword.status == SEARCH_STATUS.index("設定完了").to_s
      message
    end

    private
    def self.set_status(status)
  		@keyword.status = SEARCH_STATUS.index(status)
    end

    # 駅名検索
    def self.station_search(post)
      post.delete!("駅") if post.include?("駅")
      @station = Station.where(station_name: post)

      # 駅複数あった場合
      if @station.size > 1
        chofuku_flg = false
        g_cd = @station[0].station_g_cd
        @station.each do |s|
        　chofuku_flg = true if g_cd != s.station_g_cd
        end
        if chofuku_flg
          set_status("駅名重複あり")
          "どこの駅ぺこかー？都道府県で答えてぺこ！"
        else
          @keyword.station_name = @station[0].station_name
          set_status("ジャンル検索")
          "ジャンルはー？"
        end
      # 駅名が見つからない場合
      elsif @station.size == 0
        "駅名が見つからんで"
      else
        @keyword.station = @station[0].station_name
        set_status("ジャンル検索")
        "ジャンルはー？"
      end
    end

    def self.chofuku_station_search(post)
      station_name = ""
      pref = Pref.find_by(pref_name: post)
      @station.each do |s|
      station_name = "s.station_name（#{pref.pref_name}）"  if pref.pref_cd == s.pref_cd
      end
      @keyword.station_name = station_name
      set_status("ジャンル検索")
      "ジャンルはー？"
    end

    def self.genre_search(post)
        @keyword.genre = post
        set_status("予算検索")
        "予算はいくらまで出すー？"
    end

  end
