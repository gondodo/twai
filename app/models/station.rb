class Station < ActiveRecord::Base
  belongs_to :pref, foreign_key: :pref_cd

end
