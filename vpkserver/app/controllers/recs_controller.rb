class RecsController < ApplicationController
  http_basic_authenticate_with :name=>"admin", :password=>"vpk", :except=>[:index]

  def index
    @recs = Rec.where(:deleted => nil)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @recs }
    end
  end

  def destroy
    @rec = Rec.find(params[:id])
    @rec.deleted = true
    @rec.save

    respond_to do |format|
      format.html { redirect_to recs_url }
      format.json { head :no_content }
    end
  end
end
