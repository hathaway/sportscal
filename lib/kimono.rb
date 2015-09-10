class Kimono
  include HTTParty
  base_uri 'www.kimonolabs.com'

  def initialize(apikey="67f478848e993e8ee8bd5c8910e96c68")
    @options = { query: {apikey: apikey, kimmodify: 1} }
  end

  def teams
    self.class.get("/api/41odwxqc", @options)
  end

  def rankings
    self.class.get("/api/cr5f4d4k", @options)
  end

  def schedule(team)
    @options[:query][:kimpath3] = team.yahoo_slug
    self.class.get("/api/ondemand/21almhq6", @options)
  end

  def game(slug)
    @options[:query][:kimpath2] = slug
    self.class.get("/api/ondemand/7o7tbq06", @options)
  end

  def top25
    self.class.get("/api/cduozrcc", @options)
  end

end
