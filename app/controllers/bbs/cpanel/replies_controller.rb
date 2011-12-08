# coding: utf-8  
class Bbs::Cpanel::RepliesController <  Bbs::Cpanel::ApplicationController
  # GET /replies
  # GET /replies.xml
  def index
    @replies = LandReply.desc(:_id).paginate :page => params[:page], :per_page => 30

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @replies }
    end
  end

  # GET /replies/1
  # GET /replies/1.xml
  def show
    @reply = LandReply.find(params[:id])
    if @reply.topic.blank?
      redirect_to bbs_cpanel_replies_path, :alert => "帖子已经不存在"
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @reply }
    end
  end

  # GET /replies/new
  # GET /replies/new.xml
  def new
    @reply = LandReply.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @reply }
    end
  end

  # GET /replies/1/edit
  def edit
    @reply = LandReply.find(params[:id])
  end

  # POST /replies
  # POST /replies.xml
  def create
    @reply = LandReply.new(params[:land_reply])

    respond_to do |format|
      if @reply.save
        format.html { redirect_to(bbs_cpanel_replies_path, :notice => 'LandReply was successfully created.') }
        format.xml  { render :xml => @reply, :status => :created, :location => @reply }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @reply.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /replies/1
  # PUT /replies/1.xml
  def update
    @reply = LandReply.find(params[:id])

    respond_to do |format|
      if @reply.update_attributes(params[:land_reply])
        format.html { redirect_to(bbs_cpanel_replies_path, :notice => 'LandReply was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @reply.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /replies/1
  # DELETE /replies/1.xml
  def destroy
    @reply = LandReply.find(params[:id])
    @reply.destroy

    respond_to do |format|
      format.html { redirect_to(bbs_cpanel_replies_path) }
      format.xml  { head :ok }
    end
  end
end
