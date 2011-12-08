# coding: utf-8  
class Bbs::Cpanel::TopicsController <  Bbs::Cpanel::ApplicationController
  # GET /topics
  # GET /topics.xml
  def index
    @topics = LandTopic.unscoped.desc(:_id).includes(:user).paginate :page => params[:page], :per_page => 30

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @topics }
    end
  end

  # GET /topics/1
  # GET /topics/1.xml
  def show
    @topic = LandTopic.unscoped.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @topic }
    end
  end

  # GET /topics/new
  # GET /topics/new.xml
  def new
    @topic = LandTopic.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @topic }
    end
  end

  # GET /topics/1/edit
  def edit
    @topic = LandTopic.unscoped.find(params[:id])
  end

  # POST /topics
  # POST /topics.xml
  def create
    @topic = LandTopic.new(params[:land_topic])

    respond_to do |format|
      if @topic.save
        format.html { redirect_to(bbs_cpanel_topics_path, :notice => 'LandTopic was successfully created.') }
        format.xml  { render :xml => @topic, :status => :created, :location => @topic }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @topic.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /topics/1
  # PUT /topics/1.xml
  def update
    @topic = LandTopic.unscoped.find(params[:id])

    respond_to do |format|
      if @topic.update_attributes(params[:land_topic])
        format.html { redirect_to(bbs_cpanel_topics_path, :notice => 'LandTopic was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @topic.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /topics/1
  # DELETE /topics/1.xml
  def destroy
    @topic = LandTopic.unscoped.find(params[:id])
    @topic.destroy

    respond_to do |format|
      format.html { redirect_to(bbs_cpanel_topics_path) }
      format.xml  { head :ok }
    end
  end
end
