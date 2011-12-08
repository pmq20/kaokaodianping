# coding: UTF-8
class Cpanel::CommentsController < CpanelController
  
  def index
    params[:q] = params[:q].strip if params[:q] if params[:q]
    @comments = Comment.includes([:user])
    @comments = @comments.where(:body=>/#{params[:q]}/) if params[:q]
    @comments = @comments.desc("created_at").paginate(:page => params[:page], :per_page => 20)


    respond_to do |format|
      format.html # index.html.erb
      format.json
    end
  end

  def show
    @comment = Comment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json
    end
  end
  
  def new
    @comment = Comment.new

    respond_to do |format|
      format.html # new.html.erb
      format.json
    end
  end
  
  def edit
    @comment = Comment.find(params[:id])
  end
  
  def create
    @comment = Comment.new(params[:comment])

    respond_to do |format|
      if @comment.save
        format.html { redirect_to(cpanel_comments_path, :notice => 'Comment 创建成功。') }
        format.json
      else
        format.html { render :action => "new" }
        format.json
      end
    end
  end
  
  def update
    @comment = Comment.find(params[:id])

    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        format.html { redirect_to(cpanel_comments_path, :notice => 'Comment 更新成功。') }
        format.json
      else
        format.html { render :action => "edit" }
        format.json
      end
    end
  end
  
  def destroy
    @comment = Comment.find(params[:id])
    CommentLog.any_of(target_id:@comment.id,target_ids:@comment.id,target_parent_id:@comment.id).destroy_all
    @comment.delete

    respond_to do |format|
      format.html { redirect_to(cpanel_comments_path,:notice => "删除成功。") }
      format.json
    end
  end
end
