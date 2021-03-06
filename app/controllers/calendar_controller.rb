class CalendarController < ApplicationController
  def index
    k = Kimono.new
    response = k.top25
    games = response['results']['collection1']
    cal = Icalendar::Calendar.new

    cal.timezone do |t|
      t.tzid = "America/New_York"

      t.daylight do |d|
        d.tzoffsetfrom = "-0400"
        d.tzoffsetto   = "-0300"
        d.tzname       = "EDT"
        d.dtstart      = "19700308T020000"
        d.rrule        = "FREQ=YEARLY;BYMONTH=3;BYDAY=2SU"
      end

      t.standard do |s|
        s.tzoffsetfrom = "-0300"
        s.tzoffsetto   = "-0400"
        s.tzname       = "EST"
        s.dtstart      = "19701101T020000"
        s.rrule        = "FREQ=YEARLY;BYMONTH=11;BYDAY=1SU"
      end
    end

    tzid = "America/New_York"

    games.each do |game|
      include_game = false
      mode = params[:mode] || "all"

      home_rank = ""
      visitor_rank = ""
      unless game["home team"]["text"].nil?
        home_rank = game["home team"]["text"].match(/^\d*/)[0]
      end
      unless game["visitor team"]["text"].nil?
        visitor_rank = game["visitor team"]["text"].match(/^\d*/)[0]
      end

      home_team = ""
      visitor_team = ""

      unless game["home team"]["text"].nil?
        home_team = game["home team"]["text"]
      end
      unless game["visitor team"]["text"].nil?
        visitor_team = game["visitor team"]["text"]
      end

      #favorites
      is_favorite = false
      if home_team.include?("Notre Dame") or home_team.include?("Ohio St") or
        visitor_team.include?("Notre Dame") or visitor_team.include?("Ohio St")
        is_favorite = true
      end

      is_top25 = false
      # top 25 matchup
      unless home_rank == "" or visitor_rank == ""
        is_top25 = true
      end

      if mode == "all"
        include_game = true
      elsif mode == "top25"
        include_game = true if is_top25
      elsif mode == "favorites"
        include_game = true if is_favorite
      elsif mode == "custom"
        include_game = true if is_favorite or is_top25
      end

      if home_team == "" or visitor_team == ""
        include_game = false
      end

      if include_game
        start_time = game['game time']['data-date'].to_datetime
        tz = TZInfo::Timezone.get('America/New_York')
        start_time = tz.utc_to_local(start_time)
        end_time = start_time + 3.5.hours

        cal.event do |e|
          e.dtstart     = Icalendar::Values::DateTime.new start_time, 'tzid' => tzid
          e.dtend       = Icalendar::Values::DateTime.new end_time, 'tzid' => tzid
          e.summary     = "#{visitor_team} vs #{home_team}".squish
          e.description = "#{game["venue"]} in #{game["location"]}\n#{game["line"]}"
          e.location    = game["network"]
        end
      end
    end

    cal.publish
    headers['Content-Type'] = "text/calendar; charset=UTF-8"
    render text: cal.to_ical
  end
end
