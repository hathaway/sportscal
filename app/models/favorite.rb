class Favorite < ActiveRecord::Base
  validates :team_id,
    uniqueness: { scope: :user_id, message: "team can only be favorited once" }
  belongs_to :team
  belongs_to :user
end
