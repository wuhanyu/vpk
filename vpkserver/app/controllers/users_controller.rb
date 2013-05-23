class UsersController < ApplicationController
  def show
    @user = User.where(:uid => params[:uid]).first

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end
end
