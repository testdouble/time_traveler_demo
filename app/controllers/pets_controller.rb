class PetsController < ApplicationController
  def index
    @pet = Pet.first
  end

  def create
    @pet = Pet.create!(params[:pet].permit(:name))
    redirect_to pets_path
  end

  def destroy
    Pet.first.delete
    redirect_to pets_path
  end
end
