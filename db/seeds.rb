require "csv"

num = 0
CSV.foreach('db/pref.csv') do |row|
  # ヘッダーをスキップ
  if num == 0
    num += 1
    next
  end
  Pref.create(pref_cd: row[0], pref_name: row[1])
end

num = 0
CSV.foreach('db/station20170403free.csv') do |row|
  # ヘッダーをスキップ
  if num == 0
    num += 1
    next
  end
  Station.create(station_cd: row[0], station_g_cd: row[1], station_name: row[2], line_cd: row[5], pref_cd: row[6], post: row[7], add: row[8], lon: row[9], lat: row[10], )
end
