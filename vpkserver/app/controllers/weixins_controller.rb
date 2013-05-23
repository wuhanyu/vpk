# -*- encoding : utf-8 -*-
class WeixinsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :check_weixin_legality
  
  def show
    render :text => params[:echostr]
  end

  def create
    createUserIfHasnt
    if params[:xml][:MsgType] == "text" 
      react
    elsif params[:xml][:MsgType] == "voice"
      render "confirm", :formats => :xml
      @user_status = "normal"
    elsif params[:xml][:MsgType] == "event"
      if params[:xml][:Event] == "subscribe"
        render "welcome", :formats => :xml
      else
        render "errorreply", :formats => :xml
      end
    else
      render "errorreply", :formats => :xml
    end
    
    
    recordlog
  end
  
  private
  # 根据文本消息进行状态变化
  def react
    @text = params[:xml][:Content]
    if @text == "听"
      @pkuser.user_status = "rate"
      @pkuser.rate_at = "456"
      @pkuser.rate_count = 1
      @pkuser.save
      render "rate", :formats => :xml
    elsif @text.downcase == "a"
      checkRate
      if @flag
        rateCount
      end
    elsif @text.downcase == "b"
      checkRate
      if @flag
        rateCount
      end
    elsif @text.downcase == "pk"
      render "pk", :formats => :xml
    elsif @text == "排行榜"
      @users = User.order("overall_rating DESC").limit(10)
      render "rank", :formats => :xml
    elsif @text == "帮助"
      render "help", :formats => :xml
    elsif @text == "退出"
      render "exit", :formats => :xml
    elsif @text == "保存"
      render "voicereply", :formats => :xml
    else
      render "echo", :formats => :xml
    end 
  end
  
  private
  # 根据参数校验请求是否合法，如果非法返回错误页面
  def check_weixin_legality
    array = [Rails.configuration.weixin_token, params[:timestamp], params[:nonce]].sort
    render :text => "Forbidden", :status => 403 if params[:signature] != Digest::SHA1.hexdigest(array.join)
  end
  
  private
  # log
  def recordlog
    @log = Log.new(:content=> params[:xml][:Content],
    :type=> params[:xml][:MsgType],
    :time=> Time.at(params[:xml][:CreateTime].to_i),
    :fromUser=> params[:xml][:FromUserName],
    )
    @log.save
  end
  
  private
  #user
  def createUserIfHasnt
    @pkuser = Pkuser.where(:openid => params[:xml][:FromUserName]).first
    if @pkuser != nil
      @pkuser.last_active_at = Time.now
      @pkuser.save
    else
      user_count = Pkuser.count
      @pkuser = Pkuser.new(:openid => params[:xml][:FromUserName],
      :created_at => Time.now,
      :last_active_at => Time.now,
      :uid => (user_count + 1).to_s)
      @pkuser.save
    end
  end
  
  private
  #check rate
  def checkRate
    if @pkuser.user_status == "rate"
      @flag = true
    else
      render "errorab", :formats => :xml
      @flag = false
    end
  end
  
  
  private
  #rate count
  def rateCount
      @pkuser.rate_count = @pkuser.rate_count + 1
      if @pkuser.rate_count > 5
        @pkuser.user_status = "normal"
        render "rateover", :formats => :xml
      else
        @pkuser.user_status = "rate"
        render "rate", :formats => :xml
      end
      @pkuser.save    
  end
end
