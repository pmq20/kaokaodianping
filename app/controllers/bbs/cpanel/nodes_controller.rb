# coding: utf-8  
class Bbs::Cpanel::NodesController <  Bbs::Cpanel::ApplicationController
  # GET /nodes
  # GET /nodes.xml
  def index
    @nodes = LandNode.sorted

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @nodes }
    end
  end

  # GET /nodes/1
  # GET /nodes/1.xml
  def show
    @node = LandNode.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @node }
    end
  end

  # GET /nodes/new
  # GET /nodes/new.xml
  def new
    @node = LandNode.new    

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @node }
    end
  end

  # GET /nodes/1/edit
  def edit
    @node = LandNode.find(params[:id])
  end

  # POST /nodes
  # POST /nodes.xml
  def create
    @node = LandNode.new(params[:land_node])    

    respond_to do |format|
      if @node.save
        format.html { redirect_to(bbs_cpanel_nodes_path, :notice => 'LandNode was successfully created.') }
        format.xml  { render :xml => @node, :status => :created, :location => @node }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @node.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /nodes/1
  # PUT /nodes/1.xml
  def update
    @node = LandNode.find(params[:id])

    respond_to do |format|
      if @node.update_attributes(params[:land_node])
        format.html { redirect_to(bbs_cpanel_nodes_path, :notice => 'LandNode was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @node.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /nodes/1
  # DELETE /nodes/1.xml
  def destroy
    @node = LandNode.find(params[:id])
    @node.destroy

    respond_to do |format|
      format.html { redirect_to(bbs_cpanel_nodes_url) }
      format.xml  { head :ok }
    end
  end
end
