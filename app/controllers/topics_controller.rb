# coding: utf-8
class TopicsController < ApplicationController

  def fol
    suc=0
    params[:q].split(',').each do |id|
      t=Topic.where(name:(id.strip)).first

if t
      current_user.follow_topic(t)
suc+=1
end
    end
    render text:suc
  end

  def unfol
    suc=0
    params[:q].split(',').each do |id|
      t=Topic.where(name:(id.strip)).first
  if t
    current_user.unfollow_topic(t)
    suc+=1
  end
    end
     render text:suc
  end


  def index
    @topics = Topic.desc('answers_count')
  end

  def show_s
    name = params[:id].strip
    @per_page = 300
    @topic = Topic.find_by_name(name)
    if @topic.blank?
      return render_404
    end
    @asks = Ask.desc('answers_count').where(:topics => name,:type=>'学校')
    @asks = @asks.normal.recent.paginate(:page => params[:page], :per_page => @per_page)
    @ask_ids = @asks.collect(&:id)
    set_seo_meta(@topic.name,:description => @topic.summary)
    @related_experts = User.where(:is_expert.ne=>nil).where(:tags=>name).limit(5).to_a.sort{|x,y| x.answers.any_in(:ask_id=>@ask_ids).count <=> y.answers.any_in(:ask_id=>@ask_ids).count}
    if !params[:page].blank?
      render "/asks/index.js"
    else
      render action:'show'
    end
  end
  
  def show_cc
    name = params[:id].strip
    @per_page = 300
    @topic = Topic.find_by_name(name)
    if @topic.blank?
      return render_404
    end
    @asks = Ask.desc('answers_count').where(:topics => name,:type=>nil)
    @asks = @asks.normal.recent.paginate(:page => params[:page], :per_page => @per_page)
    @ask_ids = @asks.collect(&:id)
    set_seo_meta(@topic.name,:description => @topic.summary)
    @related_experts = User.where(:is_expert.ne=>nil).where(:tags=>name).limit(5).to_a.sort{|x,y| x.answers.any_in(:ask_id=>@ask_ids).count <=> y.answers.any_in(:ask_id=>@ask_ids).count}
    if !params[:page].blank?
      render "/asks/index.js"
    else
      render action:'show'
    end
  end

  def show
    name = params[:id].strip
    @per_page = 300
    @topic = Topic.find_by_name(name)
    if @topic.blank?
      return render_404
    end
    # @asks0=Ask.where(:topics => name)
    # if 1==@asks0.count
    #   redirect_to @asks0.first
    #   return
    # end
    @asks = Ask.desc('answers_count').where(:topics => name,:type=>'课程')
    @asks = @asks.normal.recent.paginate(:page => params[:page], :per_page => @per_page)
    @ask_ids = @asks.collect(&:id)
    set_seo_meta(@topic.name,:description => @topic.summary)
    @related_experts = User.where(:is_expert.ne=>nil).where(:tags=>name).limit(5).to_a.sort{|x,y| x.answers.any_in(:ask_id=>@ask_ids).count <=> y.answers.any_in(:ask_id=>@ask_ids).count}
    if 0==@asks.count
      redirect_to show_s_topic_path(@topic.name)
      return
    end
    if !params[:page].blank?
      render "/asks/index.js"
    else
      render action:'show'
    end
  end
  
  def follow
    @topic = Topic.find_by_name(params[:id].unpack('C*').pack('U*'))
    if not @topic
      render :text => "0"
      return
    end
    current_user.follow_topic(@topic)
    render :text => "1"
  end
  
  def unfollow
    @topic = Topic.find_by_name(params[:id].unpack('C*').pack('U*'))
    if not @topic
      render :text => "0"
      return
    end
    current_user.unfollow_topic(@topic)
    render :text => "1"
  end

  def edit
    @topic = Topic.find(params[:id])
    render :layout => false
  end

  def update
    @topic = Topic.find(params[:id])
    @topic.current_user_id = current_user.id
if !params[:topic]
redirect_to  topic_path(@topic.name)
return
end
    @topic.cover = params[:topic][:cover]
    if @topic.save
      flash[:notice] = "话题封面上传成功。"
    else
      flash[:alert] = "话题封面上传失败，请检查你上传的图片适合符合格式要求。"
    end
    redirect_to topic_path(@topic.name)
  end
end
