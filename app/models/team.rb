class Team < ActiveRecord::Base
  belongs_to :conference

  def self.update_ranking(name, poll, rank)
    t = Team.find_by_name name
    unless t.nil?
      t.update_column(poll, rank)
    end
  end
end
