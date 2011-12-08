# coding: utf-8
class LogsController < ApplicationController
  def index
    @per_page = 20
    @logs = Log.desc("$natural")
               .paginate(:page => params[:page], :per_page => @per_page)

#.not_in(:action => ["ADD_TOPIC","INVITE_TO_ANSWER"])
  end
end
