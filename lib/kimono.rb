class Kimono
  include HTTParty
  base_uri 'www.kimonolabs.com'

  def initialize(apikey="67f478848e993e8ee8bd5c8910e96c68")
    @options = { query: {apikey: apikey, kimmodify: 1} }
  end

  def teams
    self.class.get("/api/41odwxqc", @options)
  end

end
