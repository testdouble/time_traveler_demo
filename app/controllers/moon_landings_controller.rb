class MoonLandingsController < ApplicationController
  def index
    @moon_landings = MoonLanding.all
  end

  def create
    MoonLanding.create!(params[:moon_landing].permit(:name))
    redirect_to moon_landings_path
  end

  def destroy
    MoonLanding.find(params[:id]).delete
    redirect_to moon_landings_path
  end
end
