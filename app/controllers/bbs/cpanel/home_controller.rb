# coding: utf-8  
class Bbs::Cpanel::HomeController < Bbs::Cpanel::ApplicationController
  def index
    @recent_topics = LandTopic.recent.limit(5)
  end
end
