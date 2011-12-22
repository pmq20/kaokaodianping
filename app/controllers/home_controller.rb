# coding: utf-8
class HomeController < ApplicationController
  before_filter :require_user_text, :only => [:update_in_place,:mute_suggest_item]
  before_filter :require_user, :except => [:about,:index,:under_construction,:tuan,:exp,:cards,:contact]
  def tuan
    redirect_to root_path,:notice=>'考考点评的课程团购栏目将在3月1日开启，请持续关注：）'
  end
  def exp
    redirect_to root_path,:notice=>'考考点评的试听信息发布将在3月1日开启，请持续关注：）'
  end
  def cards
    redirect_to root_path,:notice=>'考考点评的会员卡发放将在3月1日开启，请持续关注：）'
  end
def contact
end

  def under_construction
  end

  def aggrement
  end
  
  def tmp
  end
  
  def index
    @hot_searches = %w(留学服务 GRE 托福 雅思 GMAT 会计 考研英语 考研数学 考研政治 计算机 西班牙语 德语 公务员 四六级 证券 教师证 司法类 驾校)
    @more_tags = Tag.all.collect(&:name)
    @more_tags.delete_if{|x| @hot_searches.include?(x)}
    @more_topics = Topic.all.collect(&:name)
    @per_page = 20
    if current_user
      @notifies, @notifications = current_user.unread_notifies
      if current_user.following_ids.size == 0 and current_user.followed_ask_ids.size == 0 and current_user.followed_topic_ids.size == 0
        @i_am_newbie = true
      end
    end
    @answers = Answer.normal.recent.limit(50)
    
    @already=[]
    @already = current_user.followed_topic_ids if user_signed_in?
    @already_names = @already.collect{|id| if topic=Topic.where(_id:id).first;topic.name;else;nil;end}.compact
    @topics = []
    @topics = TopicCache.not_in(name:@already_names).limit(12).to_a
    @bbs_topics = LandTopic.desc(:created_at).limit(30)
    # @newasks= AskCache.limit(50).collect{|ask_cache| Ask.where(:_id=>ask_cache.ask_id).first}
    @asks = Ask.where(type:nil).limit(30).each
    @users = User.normal.desc(:created_at).limit(30)
    
    if params[:format] == "js"
      render "/asks/index.js"
    end
    #   
    #   if current_user.following_ids.size == 0 and current_user.followed_ask_ids.size == 0 and current_user.followed_topic_ids.size == 0
    #     redirect_to newbie_path and return
    #   else
    #     # TODO: 这里需要过滤掉烂点评
    #     @logs = Log.any_of({:user_id.in => current_user.following_ids},
    #                        {:target_id.in => current_user.followed_ask_ids})
                              # .and(:action.in => ["NEW","NEW_ANSWER_COMMENT","NEW_ASK_COMMENT", "AGREE", "EDIT"], :_type.in => ["AskLog", "AnswerLog", "CommentLog", "UserLog"])
    #                       .excludes(:user_id => current_user.id).desc("$natural")
    #                       .paginate(:page => params[:page], :per_page => @per_page)
    #     
    #     if @logs.count < 1
    #       @asks = Ask.normal.any_of({:topics.in => current_user.followed_topics.map{|t| t.name}}).not_in(:follower_ids => [current_user.id])
    #       @asks = @asks.includes(:user,:last_answer,:last_answer_user,:topics)
    #                     .has_answer
    #                     .exclude_ids(current_user.muted_ask_ids)
    #                     .desc(:answers_count,:answered_at)
    #                     .paginate(:page => params[:page], :per_page => @per_page)
    #                     
    #       if params[:format] == "js"
    #         render "/asks/index.js"
    #       end
    #     else
    #       if params[:format] == "js"
    #         render "/logs/index.js"
    #       else
    #         render "/logs/index"
    #       end
    #     end
    #   end
    # else

    # end
  end
  
  def newbie
    @notifies, @notifications = current_user.unread_notifies
    ask_logs = Log.any_of({:_type => "AskLog"}, {:_type => "UserLog", :action.in => ["FOLLOW_ASK", "UNFOLLOW_ASK"]}).where(:created_at.gte => (Time.now - 12.hours))
    answer_logs = Log.any_of({:_type => "AnswerLog"}, {:_type => "UserLog", :action => "AGREE"}).where(:created_at.gte => (Time.now - 12.hours))
    @asks = Ask.normal.any_of({:_id.in => ask_logs.map {|l| l.target_id}.uniq}, {:_id.in => answer_logs.map {|l| l.target_parent_id}.uniq}).order_by(:answers_count.asc, :views_count.asc)
    h = {} 
    # 将回答次数*topic，以加入回答次数
    @hot_topics = @asks.inject([]) { |memo, ask|
      memo += ask.topics
    }
    @hot_topics.delete("者也")
    @hot_topics.delete("知乎")
    @hot_topics.delete("反馈")
    @hot_topics.delete("zheye")
    @hot_topics.delete("Quora")
    @hot_topics.delete("quora")
    
    @hot_topics.each { |str| 
      h[str] = (h[str] || 0) + 1 
    }
    @hot_topics = h.sort{|a, b|b[1]<=>a[1]}.collect{|tmp|tmp[0]}[0..8]
  end
  
  
  def timeline
    @per_page = 20
    # @logs = Log.any_in(:user_id => curr)
  end
  
  def followed
    @per_page = 20
    @asks = current_user ? current_user.followed_asks.normal : Ask.normal
    @asks = @asks.includes(:user,:last_answer,:last_answer_user,:topics)
                  .exclude_ids(current_user.muted_ask_ids)
                  .desc(:answered_at,:id)
                  .paginate(:page => params[:page], :per_page => @per_page)

    if params[:format] == "js"
      render "/asks/index.js"
    else
      render "index0"
    end
  end
  
  def recommended
    @per_page = 20
    @asks = current_user ? Ask.normal.any_of({:topics.in => current_user.followed_topics.map{|t| t.name}}).not_in(:follower_ids => [current_user.id]).and(:answers_count.lt => 1) : Ask.normal
    @asks = @asks.where(:to_user_id=>nil).includes(:user,:last_answer,:last_answer_user,:topics)
                  .exclude_ids(current_user.muted_ask_ids)
                  .desc(:answers_count,:answered_at)
                  .paginate(:page => params[:page], :per_page => @per_page)

    if params[:format] == "js"
      render "/asks/recommended.js"
    end
  end

  def muted
    @per_page = 20
    @asks = Ask.normal.includes(:user,:last_answer,:last_answer_user,:topics)
                  .only_ids(current_user.muted_ask_ids)
                  .desc(:answered_at,:id)
                  .paginate(:page => params[:page], :per_page => @per_page)
  
    set_seo_meta("我屏蔽掉的点评")
  
    if params[:format] == "js"
      render "/asks/index.js"
    else
      render "index0"
    end
  end

  def update_in_place
    # TODO: Here need to chack permission
    klass, field, id = params[:id].split('__')
    puts params[:id]

    # 验证权限,用户是否有修改制定信息的权限
    case klass
    when "user" then return if current_user.id.to_s != id
    end
    
    params[:value] = simple_format(params[:value].to_s.strip) if params[:did_editor_content_formatted] == "no"

    object = klass.camelize.constantize.find(id)
    update_hash = {field => params[:value]}
    if ["ask","topic"].include?(klass) and current_user
      update_hash[:current_user_id] = current_user.id
    end
    if object.update_attributes(update_hash)
      render :text => object.send(field).to_s
    else
      Rails.logger.info "object.errors.full_messages: #{object.errors.full_messages}"
      render :text => object.errors.full_messages.join("\n"), :status => 422
    end
  end

  # def about
  #   set_seo_meta("关于")
  #   @users = User.any_in(:email => Setting.admin_emails)
  # end

  def mark_notifies_as_read_one
    if !params[:ids]
      render :text => "0"
    else
      notifications = current_user.notifications.any_in(:_id => params[:ids].split(","))
      notifications.each do |notify|
        # Rails.logger.info "mark_notifies_as_read_one\n"
        notify.update_attribute(:has_read, true)
      end
      render :text => "1"
    end
  end


  def mark_notifies_as_read
    if !params[:ids]
      render :text => "0"
    else
      notifications = current_user.notifications.any_in(:_id => params[:ids].split(","))
      notifications.each do |notify|
        # Rails.logger.info "mark_notifies_as_read\n"
        notify.update_attribute(:has_read, true)
      end
      render :text => "1"
    end
  end


  def report
    name = "访客"
    if(!params[:url] or params[:url]=='')
      redirect_to '/'
      return
    end
    if current_user
      name = current_user.name
    end
    unless params[:desc] and params[:desc]!=''
      flash[:error]='不能为空'
      redirect_to params[:url].split('#').first
return
    end
    ReportSpam.add(params[:url],params[:desc],name)
    flash[:notice] = "举报信息已经提交，谢谢你。"
    redirect_to params[:url].split('#').first
  end

  def mute_suggest_item
    UserSuggestItem.mute(current_user.id, params[:type].strip.titleize, params[:id])
    render :text => "1"
  end

end
