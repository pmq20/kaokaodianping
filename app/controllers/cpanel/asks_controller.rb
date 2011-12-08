# coding: UTF-8
class Cpanel::AsksController < CpanelController
  
  def index
    params[:q] = params[:q].strip if params[:q]
    @asks = Ask.includes([:user])
    @asks = @asks.where(:title=>/(#{params[:q]})/) if params[:q]
    @asks = @asks.desc("created_at").paginate(:page => params[:page], :per_page => 40)


    respond_to do |format|
      format.html # index.html.erb
      format.json
    end
  end

  def index_un

    @asks = Ask.includes([:user]).where('this.answers_count==0').desc("created_at").paginate(:page => params[:page], :per_page => 40)

    respond_to do |format|
      format.html # index.html.erb
      format.json
    end

  end

  def show
    @ask = Ask.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json
    end
  end
  
  def new
    @ask = Ask.new

    respond_to do |format|
      format.html # new.html.erb
      format.json
    end
  end
  
  def edit
    @ask = Ask.find(params[:id])
  end
  
  def create
jigou=params[:ask].to_s.split(']').first.strip
jigou=jigou.split('[')[-1].strip
topic = Topic.where(name:jigou).first
render text:'no such jigou' and return unless topic
@ask = Ask.new(params[:ask])
@ask.topics = [jigou]

    respond_to do |format|
      if @ask.save
        format.html { redirect_to(cpanel_asks_path, :notice => 'Ask 创建成功。') }
        format.json
      else
        format.html { render :action => "new" }
        format.json
      end
    end
  end
  
  def update
    @ask = Ask.find(params[:id])
    @ask.current_user_id = current_user.id
    respond_to do |format|
      if @ask.update_attributes(params[:ask])
        format.html { redirect_to(cpanel_asks_path, :notice => 'Ask 更新成功。') }
        format.json
      else
        format.html { render :action => "edit" }
        format.json
      end
    end
  end
  
  def destroy
    @ask = Ask.find(params[:id])
    @ask.followers.each do |user|
      user.unfollow_ask(@ask)
    end
    Log.any_of(target_id:@ask.id,target_ids:@ask.id,target_parent_id:@ask.id,title:@ask.title).destroy_all
    @ask.delete

    respond_to do |format|
      format.html { redirect_to(cpanel_asks_path,:notice => "删除成功。") }
      format.json
    end
  end
end
