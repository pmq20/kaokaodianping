# coding: utf-8
class Bbs::RepliesController < BbsController
  before_filter :require_user
  
  def edit
    @reply = current_user.replies.find(params[:id])
  end
  
  def update
    @reply = current_user.replies.find(params[:id])

    if @reply.update_attributes(params[:land_reply])
      redirect_to(bbs_topic_path(@reply.topic_id), :notice => '回帖删除成功.')
    else
      render :action => "edit"
    end
  end
end