# coding: utf-8
class TraverseController < ApplicationController
  def index
    if params[:q]
      @tags = Tag.where(name:/.*#{params[:q]}.*/).to_a
      if 1==@tags.length
        redirect_to tag_path(@tags.first.name)
        return
      end
      @topics= Redis::Search.query("Topic",params[:q].strip,:limit=>30000,:sort_field=>'followers_count')
      if 1==@topics.length
        topic = Topic.find(@topics.first['id'])
        redirect_to topic_path(topic.name)
        return
      end
      @asks = Redis::Search.query("Ask",params[:q].strip,:limit => 30000)
      if 1==@asks.length
        ask = Ask.find(@asks.first['id'])
        redirect_to ask_path(ask)
        return
      end
    end
  end

  def asks_from
    start = params[:current_key].to_i*20
    @asks= Redis::Search.query("Ask",params[:q],:limit=>start+20+1)
    @more =(@asks.size-start>20)
 if @asks.size-start>20
    @asks=@asks[start..start+19]
else
 @asks=@asks[start..-1]
end
    @asks||=[]
    render layout:false
  end
end
