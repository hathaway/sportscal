class Game < ActiveRecord::Base
  has_one :visitor_team, class_name: "Team"
  has_one :home_team, class_name: "Team"
end
