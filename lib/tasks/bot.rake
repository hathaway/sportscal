require 'kimono'

desc "This task crawls all teams and saves them to the database."
namespace :bot do
	task :crawl_teams => :environment do
		k = Kimono.new
		results = k.teams

		teams = results["results"]["teams"]

		teams.each do |team|
			if Team.find_by_name(team["name"]["text"]).nil?
				# Check for conference
				c = Conference.find_by_abbreviation team["conference"]
				c = Conference.create(abbreviation: team["conference"]) if c.nil?

				t = Team.new

				t.name = team["name"]["text"]
				t.division = team["division"]
				t.conference = c
				t.yahoo_url = team["name"]["href"]
				t.yahoo_slug = /teams\/(.*)/.match(t.yahoo_url)[1]
				t.save
				puts "Saved #{t.name}"
			else
				puts "Skipped #{team["name"]["text"]}"
			end
		end
	end

	task :crawl_rankings => :environment do
		k = Kimono.new
		results = k.rankings

		ap_rankings = results["results"]["ap"]
		Team.update_all :ap_rank => nil
		ap_rankings.each do |ranking|
			Team.update_ranking(ranking["team"]["text"], :ap_rank, ranking["rank"].sub(".", "").to_i)
		end

		ap_rankings = results["results"]["coaches"]
		Team.update_all :coaches_rank => nil
		ap_rankings.each do |ranking|
			Team.update_ranking(ranking["team"]["text"], :coaches_rank, ranking["index"]-25)
		end
	end
end
