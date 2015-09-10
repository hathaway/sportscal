require 'kimono'
#require 'scraper'

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

	task :crawl_games => :environment do
		k = Kimono.new
		#teams = Team.all
		teams = Team.where(name: "Notre Dame")

		teams.each do |team|
			response = k.schedule team
			if response.nil?
				puts "No schedule response for #{team.name}"
				next
			end
			games = response["results"]["collection1"]
			games.each do |game|
				date = game["date"].match(/Week \d*: (.*)/)[1]
				time = game["time"]
				game_time = "#{date} #{time}".to_datetime
				home_team = Team.find_by_name game["home team"]
				visitor_team = Team.find_by_name game["visitor team"]

				g = Game.where(home_team: home_team).where(visitor_team: visitor_team).where(start_time: game_time).first
				g = Game.new if g.nil?
				g.start_time = game_time
				g.home_team = home_team
				g.visitor_team = visitor_team
				g.yahoo_url = game["game info"]["href"]
				g.save
			end
			puts "Saved schedule for #{team.name}"
			sleep 10
		end
	end

	task :update_games => :environment do
		# update game time, network, score based on game page
		games = Game.all
		games.each do |g|
			slug = g.yahoo_url.match(/ncaaf\/(.*)\//)[1]
			k = Kimono.new
			response = k.game(slug)
			if response.nil?
				puts "Bad response for #{g.id}"
				next
			end
			game = response["results"]["collection1"].first
			g.start_time = game["game time"].to_datetime
			g.network = game["network"]
			g.save
			puts "Updated #{g.id}"
		end
	end

	task :crawl_schedule => :environment do
		# require 'open-uri'
		# doc = Nokogiri::HTML(open("http://scores.espn.go.com/college-football/schedule"))
		# times = doc.css("table.schedule td[data-behavior='date_time']").map{|n| n["data-date"]}
		#
		# home_teams = doc.css("table.schedule td.home a.team-name span").map{|n| n.text}
		# visitor_teams = doc.css("table.schedule td:not(.home) a.team-name span").map{|n| n.text}

		data = Wombat.crawl do
			base_url "http://scores.espn.go.com"
		  path "/college-football/schedule"
			games do
				#times "css=table.schedule td[data-behavior='date_time']", :list
		    home_teams "css=table.schedule td.home a.team-name span", :list
		    visitor_teams "css=table.schedule td:not(.home) a.team-name span", :list
			end
		end

		pp data


	end
end
