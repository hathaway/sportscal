class Scraper
  include Wombat::Crawler

  base_url "http://scores.espn.go.com"
  path "/college-football/schedule"

  games do
    times "css=table.schedule td[data-behavior='date_time']", :list
    home_teams "css=table.schedule td.home a.team-name span", :list
    visitor_teams "css=table.schedule td:not(.home) a.team-name span", :list
  end

end
