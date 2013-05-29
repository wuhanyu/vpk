# -*- encoding : utf-8 -*-
class WeixinsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :check_weixin_legality
  
  def show
    render :text => params[:echostr]
  end

  def create
    createUserIfHasnt
    @flag = true
    if params[:xml][:MsgType] != "event"
      checkNewUser
    end
    if @flag == true
      if params[:xml][:MsgType] == "text" 
        react
      elsif params[:xml][:MsgType] == "voice"
        render "confirm", :formats => :xml
        @user_status = "normal"
      elsif params[:xml][:MsgType] == "event"
        if params[:xml][:Event] == "subscribe"
          @ccount = User.all.count
          render "welcome", :formats => :xml
        else
          render "errorreply", :formats => :xml
        end
      elsif params[:xml][:MsgType] == "image"
        @user.avatar_url = params[:xml][:PicUrl]
        @user.save
        render "imageupload", :formats => :xml
      else
        render "errorreply", :formats => :xml
      end
    end
    recordlog
  end
  
  private
  # 根据文本消息进行状态变化
  def react
    @text = params[:xml][:Content].strip
    if @text == "随便听"
      # @randomplay = Webrc.limit(1).offset(rand(Webrc.count)).first
      # render "randomplay", :formats => :xml
      @recs = Rec.where(:MediaId.exists => true)
      @mediaid = @recs.limit(1).offset(rand(@recs.count)).first.MediaId
      render "randommeng2", :formats => :xml
    elsif @text == "随便萌"
      @recs = Rec.where(:MediaId.exists => true)
      @mediaid = @recs.limit(1).offset(rand(@recs.count)).first.MediaId
      render "randommeng2", :formats => :xml
      # @randommengs = Rec.where(:uid => @user.meng)
      # if @randommengs.count > 0
        # @ccount = rand(@randommengs.count)
        # @randommeng = @randommengs.limit(1).offset(@ccount).first
        # @tuser = User.where(:uid=>@randommeng.uid).first
        # render "randommeng", :formats => :xml
      # else
        # @texttext = "您现在还没有可听的萌声音哦，回复【萌 昵称】萌别人试试~"
        # render "texttext", :formats => :xml
      # end
    elsif (@text.downcase == "a" || @text.downcase == "b" || @text.downcase == "p")
      @rs = @text.downcase
      checkRate
      if @flag
        recordResult
        @user.user_status = "normal"
        # rateCount
      end
    elsif (@text.downcase == "pk" or @text == "说")
      @user.user_status = "pk"
      render "pk", :formats => :xml
    elsif @text == "排行榜"
      @users = User.where(:overall_rating.gt => 0).order("overall_rating DESC").limit(10)
      render "rank", :formats => :xml
    elsif @text == "帮助"
      render "help", :formats => :xml
    elsif @text == "test"
      render "test", :formats => :xml
    elsif @text == "保存"
      @user.user_status = "normal"
      render "voicereply", :formats => :xml
    elsif @text == "我的信息" or @text == "我是谁"
      @user.rec_count = Rec.where(:uid=>@user.uid).count
      render "myinfo", :formats => :xml
    elsif @text == "笑话"
      @sampletext = Sample.where(:type => 1).limit(1).offset(rand(Sample.where(:type => 1).count)).first.content
      render "sample", :formats => :xml
    elsif @text == "调戏"
      @texttext = "坏人你调戏我，告诉麻麻听～呜呜跑开"
      render "texttext", :formats => :xml
    elsif @text == "台词"
      @sampletext = Sample.where(:type => 2).limit(1).offset(rand(Sample.where(:type => 2).count)).first.content
      render "sample", :formats => :xml
    elsif @text == "三行情书"
      @sampletext = Sample.where(:type => 5).limit(1).offset(rand(Sample.where(:type => 5).count)).first.content
      render "sample2", :formats => :xml
    elsif @text == "清唱" or @text == "唱给你听"
      render "onlyvoice", :formats => :xml
    elsif @text == "梦想"
      @texttext = "畅想未来的自己，『按下录音键』大胆勇敢地说出你的梦想！" 
      render "texttext", :formats => :xml
    elsif @text == "正毕业"
      @texttext = "临别之际，思绪万千，『按下录音键』发表毕业感言吧..." 
      render "texttext", :formats => :xml        
    elsif (@text == "听" or @text.downcase == "t")
      @user.user_status = "rate"
      getRate
      @user.rate_at = @rate._id
      @user.rate_count = 1
      render "rate", :formats => :xml
    elsif @text.include? " "
      text_command
    else
      render "help", :formats => :xml
    end
    @user.save
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
    :type => params[:xml][:MsgType],
    :time => Time.at(params[:xml][:CreateTime].to_i),
    :fromUser => params[:xml][:FromUserName],
    :MediaId => params[:xml][:MediaId],
    :CreateTime => params[:xml][:CreateTime],
    :event => params[:xml][:Event]
    )
    @log.save
  end
  
  private
  #user
  def createUserIfHasnt
    @user = User.where(:openid => params[:xml][:FromUserName]).first
    if @user != nil
      @user.last_active_at = Time.now
    else
      @user = User.new(:openid => params[:xml][:FromUserName],
      :created_at => Time.now,
      :last_active_at => Time.now,
      :meng => [],
      :menged_count => 0,
      :name => "Silent")
    end
    @user.save
  end
  
  private
  #create user
  def checkNewUser
    if @user.name == nil or @user.name == "Silent"
      @flag = false
      @text = params[:xml][:Content]
      if (params[:xml][:MsgType] == "text" and @text.include? " ")
        @name = @text.split(" ")[0]
        @tmpuser = User.where(:name => @name).first
        if (@tmpuser == nil and @name != "麦萌" and @name != "Silent")
          if @name.length <= 5
            @sex = @text.split(" ")[1]
            if (@sex=="男" or @sex=="女")
              @user.name = @name
              @user.sex = 0
              if @sex=="女"
                @user.sex = 1
              end
              if @user.save
                render "after", :formats => :xml
              else
                @errortext = @user.errors
                render "errortext", :formats => :xml
              end
            else
              @texttext = "性别请填『男』或『女』，范例格式：麦萌 女"
              render "texttext", :formats => :xml
            end
          else
            @texttext = "昵称长度不能超过5字符，请输入新的昵称，范例格式：麦萌 女"
            render "texttext", :formats => :xml            
          end
        else
          @texttext = "昵称已经被占用，请输入新的昵称，范例格式：麦萌 女"
          render "texttext", :formats => :xml         
        end
      else
        render "newuser", :formats => :xml
      end
    end
  end
  
  private
  #check rate
  def checkRate
    if @user.user_status == "rate"
      @flag = true
    else
      render "errorab", :formats => :xml
      @flag = false
    end
  end
  
  
  private
  #rate count
  def rateCount
      @user.rate_count = @user.rate_count + 1
      if @user.rate_count > 5
        @user.user_status = "normal"
        render "rateover", :formats => :xml
      else
        @user.user_status = "rate"
        getRate
        @user.rate_at = @rate.rateid
        render "rate", :formats => :xml
      end
      @user.save    
  end
  
  private
  #give rate
  def getRate
    @ccount = Rate.count(:rated_count => 0)
    if @ccount > 0
      @rate = Rate.where(:rated_count => 0).offset(rand(@ccount)).first
    else
      @rate = Rate.limit(1).offset(rand(Rate.count)).first
    end
    # @rate = Rate.limit(1).offset(rand(Rate.count)).first
  end
  
  private
  #command
  def text_command
    @command = @text.split(" ")[0]
    @target = @text.split(" ")[1]
    if @command == "排名"
      @user = User.where(:name=>@text.split(" ")[1]).first
      render "myrank", :formats => :xml
    elsif @command == "萌"
      @tuser = User.where(:name=>@target).first
      if @tuser == nil
        @texttext = "您要萌的用户不存在哦，请检查用户名是否输入正确"
        render "texttext", :formats => :xml
      else
        @mengs = @user.meng
        if @mengs.include? @tuser.uid
          @texttext = "您已经萌过啦~换个人萌萌呗~"
          render "texttext", :formats => :xml
        else
          @mengs.push(@tuser.uid)
          @user.meng = @mengs
          @user.save
          @tuser.menged_count = @tuser.menged_count + 1
          @tuser.save
          render "meng", :formats => :xml
        end
      end
    else
      render "errorcmd", :formats => :xml
    end
  end
  
  private
  #record result
  def recordResult
    @rate = Rate.where(:_id => @user.rate_at).first
    @match = Newmatch.new()
    @match.uid_a = @rate.uid_a
    @match.uid_b = @rate.uid_b
    @match.category = @rate.category
    @match.rid_a = @rate.rid_a
    @match.rid_b = @rate.rid_b
    @match.rater = @user.openid
    @match.created_at = Time.now
    @match.mid = (Newmatch.count + Oldmatch.count + 1).to_s
    if (@rs == "a")
      @match.result = 1
      @rate.wincount_a = @rate.wincount_a + 1
      @rec = Rec.where(:rid=>@rate.rid_a).first
      @uid = @rate.uid_a
    elsif (@rs == "b")
      @match.result = -1
      @rate.wincount_b = @rate.wincount_b + 1
      @rec = Rec.where(:rid=>@rate.rid_b).first
      @uid = @rate.uid_b
    else
      @match.result = 0
    end
    @match.save
    if (@rec.win_count == nil)
      @rec.win_count = 1
    else
      @rec.win_count = @rec.win_count + 1
    end
    @rec.save
    @tuser = User.where(:uid=>@uid).first
    ###############################
    if (@rate.rated_count == 0)
      Rate.where(:uid_a=>@rate.uid_a).each do |rate|
        rate.rated_count = rate.rated_count + 1
        rate.save
      end
      Rate.where(:uid_b=>@rate.uid_a).each do |rate|
        rate.rated_count = rate.rated_count + 1
        rate.save
      end
      Rate.where(:uid_a=>@rate.uid_b).each do |rate|
        rate.rated_count = rate.rated_count + 1
        rate.save
      end
      Rate.where(:uid_b=>@rate.uid_b).each do |rate|
        rate.rated_count = rate.rated_count + 1
        rate.save
      end
    end
    @rate.rated_count = @rate.rated_count + 1
    @rate.save 
    ###############################
    render "ratesuccess", :formats => :xml
  end
end
