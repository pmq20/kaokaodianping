# coding: utf-8  
class Bbs::TopicsController < BbsController
  before_filter :require_user, :only => [:new,:edit,:create,:update,:destroy,:reply]
  before_filter :init_list_sidebar, :only => [:index,:recent,:show,:cate,:search]
  caches_page :feed, :expires_in => 1.hours

  private
  def init_list_sidebar 
   if !fragment_exist? "topic/init_list_sidebar/hot_nodes"
      @hot_nodes = LandNode.hots.limit(20)
    end
    if current_user
      @user_last_nodes = LandNode.find_last_visited_by_user(current_user.id)
    end 
  end

  public
  # GET /topics
  # GET /topics.xml
  def index
    @topics = LandTopic.last_actived.limit(6)
    @sections = LandSection.all
    set_seo_meta("","#{Setting.app_name}论坛")
  end
  
  def feed
    @topics = LandTopic.recent.limit(20)
    response.headers['Content-Type'] = 'application/rss+xml'
    render :layout => false
  end

  def node
    @node = LandNode.find(params[:id])
    if current_user
      LandNode.set_user_last_visited(current_user.id, @node.id)
    end
    @topics = @node.topics.last_actived.paginate(:page => params[:page],:per_page => 50)
    set_seo_meta("#{@node.name} &raquo; 社区论坛","#{Setting.app_name}社区#{@node.name}",@node.summary)
    render :action => "index"
  end

  def recent
    @topics = LandTopic.recent.limit(50)
    set_seo_meta("最近活跃的50个帖子 &raquo; 社区论坛")
    render :action => "index"
  end

  def search
    result = Redis::Search.query("LandTopic", params[:key], :limit => 500)
    ids = result.collect { |r| r["id"] }
    @topics = LandTopic.find(ids).paginate(:page => params[:page], :per_page => 20)
    set_seo_meta("搜索#{params[:s]} &raquo; 社区论坛")
    render :action => "index"
  end

  def show
    @topic = LandTopic.find(params[:id])
    @topic.hits.incr(1)
    if current_user
      LandNode.set_user_last_visited(current_user.id, @topic.node_id)
      @topic.user_readed(current_user.id)
    end
    @node = @topic.node
    @replies = @topic.replies.all
    set_seo_meta("#{@topic.title} &raquo; 社区论坛")
  end

  # GET /topics/new
  # GET /topics/new.xml
  def new
    @topic = LandTopic.new
    @topic.node_id = params[:node]
    @node = LandNode.find(params[:node])
    if @node.blank?
      render_404
    end
    set_seo_meta("发帖子 &raquo; 社区论坛")
  end

  def reply
    @topic = LandTopic.find(params[:id])
    @reply = @topic.replies.build(params[:land_reply])        
    @reply.user_id = current_user.id
    if @reply.save
      flash[:notice] = "回复成功。"
    else
      flash[:notice] = @reply.errors.full_messages.join("<br />")
    end
    redirect_to bbs_topic_path(params[:id],:anchor => 'reply')
  end

  # GET /topics/1/edit
  def edit
    @topic = current_user.topics.find(params[:id])
    @node = @topic.node
    set_seo_meta("改帖子 &raquo; 社区论坛")
  end

  # POST /topics
  # POST /topics.xml
  def create
    pt = params[:land_topic]
    @topic = LandTopic.new(pt)
    @topic.user_id = current_user.id
    @topic.node_id = params[:land_node] || pt[:node_id]

    if @topic.save
      redirect_to(bbs_topic_path(@topic.id), :notice => '帖子创建成功.')
    else
      render :action => "new"
    end
  end

  # PUT /topics/1
  # PUT /topics/1.xml
  def update
    @topic = current_user.topics.find(params[:id])
    pt = params[:land_topic]
    @topic.node_id = pt[:node_id]
    @topic.title = pt[:title]
    @topic.body = pt[:body]

    if @topic.save
      redirect_to(bbs_topic_path(@topic.id), :notice => '帖子修改成功.')
    else
      render :action => "edit"
    end
  end

  # DELETE /topics/1
  # DELETE /topics/1.xml
  def destroy
    @topic = current_user.topics.find(params[:id])
    @topic.destroy
    redirect_to(bbs_topics_path, :notice => '帖子删除成功.')
  end
end
