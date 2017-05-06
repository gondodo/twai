class Pref < ActiveRecord::Base
  has_many :stations, foreign_key: :pref_cd

end
