class SoundsController < ApplicationController
  http_basic_authenticate_with :name=>"admin", :password=>"vpk", :except=>[:index]

  def index
    @recs = Rec.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @recs }
    end
  end

  def show
    @post = Rec.find(params[:rid])

    respond_to do |format|
      format.json { render json: @post }
    end
  end

  def destroy
    @rec = Rec.find(params[:rid])
    @rec.deleted = true
    @rec.save

    respond_to do |format|
      format.html { redirect_to posts_url }
      format.json { head :no_content }
    end
  end
end
