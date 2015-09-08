class TeamsController < ApplicationController
  before_action :authenticate_user!

  def index
    @title = "Teams"
    @teams = current_user.favorite_teams
    respond_to do |format|
      format.html
      format.json { render :json => @teams }
      format.xml { render :xml => @teams }
    end
  end

  def show
  end

  def favorite
    # save favorite
    f = current_user.favorites.create(team_id: params[:id])
    respond_to do |format|
      format.json { render :json => {success: true, favorite: f} }
    end
  end
end
