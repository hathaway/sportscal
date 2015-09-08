class HomeController < ApplicationController
  def index
    @title = "SportsCal"
    @teams = Team.all
  end
end
