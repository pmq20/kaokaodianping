# coding: UTF-8
class Cpanel::TopicsController < CpanelController
  
  def index
        params[:q] = params[:q].strip if params[:q]
    @topics = Topic
    @topics = @topics.where(:name=>/#{params[:q]}/) if params[:q]
    @topics = @topics.where(:tags => params[:tag]) if params[:tag]
    @topics = @topics.desc(params[:sort]) if params[:sort]
    @topics = @topics.desc("created_at").paginate(:page => params[:page], :per_page => 20)
    @tags = Topic.all.to_a.inject([]){|s,i| if i.tags;s+i.tags;else;[];end}
    if @tags
      @tags = @tags.uniq
    else
      @tags = []
    end



    respond_to do |format|
      format.html # index.html.erb
      format.json
    end
  end

  def show
    @topic = Topic.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json
    end
  end
  
  def new
    @topic = Topic.new

    respond_to do |format|
      format.html # new.html.erb
      format.json
    end
  end
  
  def edit
    @topic = Topic.find(params[:id])
  end
  
  def create
    @topic = Topic.new(params[:topic])

    respond_to do |format|
      if @topic.save
        format.html { redirect_to(cpanel_topics_path, :notice => 'Topic 创建成功。') }
        format.json
      else
        format.html { render :action => "new" }
        format.json
      end
    end
  end
  
  def update
    @topic = Topic.find(params[:id])
# TODO: 
    respond_to do |format|
      if @topic.update_attributes(params[:topic])
        format.html { redirect_to(cpanel_topics_path, :notice => 'Topic 更新成功。') }
        format.json
      else
        format.html { render :action => "edit" }
        format.json
      end
    end
  end
  
  def destroy
    @topic = Topic.find(params[:id])
    # 1
    TopicLog.any_of(target_id:@topic.id,target_ids:@topic.id,target_parent_id:@topic.id).delete_all
    # 2 创建话题   添加，删除话题
    @topic.followers.each do |user|
      user.unfollow_topic(@topic,false)
    end
    # 3
    Ask.where(:topics => @topic.name).each do |ask|
      ask.topics.delete @topic.name
      ask.save
    end
    # real delete
    @topic.delete
    # 4
    global_topic_calculations
    
    respond_to do |format|
      format.html { redirect_to(cpanel_topics_path,:notice => "删除成功。") }
      format.json
    end
  end
end
