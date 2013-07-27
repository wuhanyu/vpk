class RecsController < ApplicationController
  http_basic_authenticate_with :name=>"admin", :password=>"vpk", :except=>[:index]

  def index
    @recs = Rec.where(:deleted.exists => false).order("created_at")
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @recs }
    end
  end
  
  def update
    @rec = Rec.find(params[:id])
    @old_category = @rec.category
    @rec.update_attributes(params[:rec])
    @new_category = @rec.category
    if @new_category != @old_category
      @rates = Rate.where(:rid_a=>@rec.rid)
      @rates.each do |rate|
        rate.destroy
      end
      @rates = Rate.where(:rid_b=>@rec.rid)
      @rates.each do |rate|
        rate.destroy
      end
    
      @user = User.where(:uid => @rec.uid).first
      @user.recs[@old_category].delete(@rec.rid)
      if @user.recs[@new_category] == nil
        @user.recs[@new_category] = {}
      end
      @user.recs[@new_category][@rec.rid] = true
      
      @user.save
    end
    @message = "Submit Successfully"
    respond_to do |format|
      format.json { head :no_content }
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
