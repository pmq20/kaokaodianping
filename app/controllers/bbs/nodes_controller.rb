# coding: utf-8  
class Bbs::NodesController < BbsController
  # GET /nodes
  # GET /nodes.xml
  def index
    @nodes = LandNode.all
    render :json => @nodes, :only => [:name], :methods => [:id]
  end
end
