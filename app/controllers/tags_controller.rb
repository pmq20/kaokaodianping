# coding: utf-8
class TagsController < ApplicationController

  def index
    @tags = Tag.all
  end

  def show
    name = params[:id].strip
    @per_page = 10000
    @tag = Tag.where(name:name).first
    if @tag.blank?
      return render_404
    end
    more_arr = []
    @topics = @tag.topics
    if params[:more]
      @more_already = params[:more].split(',')
      @topics = @topics.also_in(:tags => @more_already)
    else
      @more_already = []
    end
    @more = @tag.more
    @more.delete_if{|x| @more_already.include?(x)}

    @topics = @topics.desc('answers_count').recent.paginate(:page => params[:page], :per_page => @per_page)
    @topic_ids = @topics.collect(&:id)
    set_seo_meta(@tag.name)
	#this is for the endless page button
    if !params[:page].blank?
      render "/topics/index.js"
    end
  end
  
end
