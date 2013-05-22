# -*- encoding : utf-8 -*-
class WeixinsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :check_weixin_legality
  
  def show
    render :text => params[:echostr]
  end

  def create 
    if params[:xml][:MsgType] == "text" 
      react
    elsif params[:xml][:MsgType] == "voice"
      render "voicereply", :formats => :xml
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
    
    createUserIfHasnt
    recordlog
  end
  
  private
  # 根据文本消息进行状态变化
  def react
    @text = params[:xml][:Content]
    @user_status = "normal"
    if @text == "听"
      @user_status = "rate"
      render "rate", :formats => :xml
    elsif @text.downcase == "pk"
      @user_status = "pk"
      render "pk", :formats => :xml
    elsif @text == "排行榜"
      render "rank", :formats => :xml
    elsif @text == "帮助"
      render "help", :formats => :xml
    elsif @text == "退出"
      render "exit", :formats => :xml
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
    @user = User.where(:openid => params[:xml][:FromUserName]).first
    if @user != nil
      @user.last_active_at = Time.now
      @user.user_status = @user_status
      @user.save
    else
      user_count = User.count
      @user = User.new(:openid => params[:xml][:FromUserName],
      :created_at => Time.now,
      :last_active_at => Time.now,
      :uid => (user_count + 1).to_s)
      @user.save
    end
  end
end
