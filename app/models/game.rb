class Game < ActiveRecord::Base
  validates :home_team_id,
    uniqueness: { scope: [:visitor_team_id, :start_time], message: "teams cannot play twice on the same date" }
  belongs_to :visitor_team, class_name: "Team"
  belongs_to :home_team, class_name: "Team"
end
