class Cpanel::StatsController < CpanelController
  def index
    
  end
  
  def uv
    #Parameters: {"datepicker_from"=>"10/18/2011", "time_from"=>"01:00", "datepicker_to"=>"10/30/2011", "time_to"=>"02:30", "commit"=>"UV查询"}
    @from_time = Time.strptime params['datepicker_from']+' '+params["time_from"],"%m/%d/%Y %H:%M"
    @to_time = Date.strptime params['datepicker_to']+' '+params["time_to"],"%m/%d/%Y %H:%M"
    @asklogs = AskLog.where(:created_at.gt=>@from_time).and(:created_at.lt=>@to_time).and(:action=>"INVITE_TO_ANSWER")
    @asks = Ask.where(:created_at.gt=>@from_time).and(:created_at.lt=>@to_time)
    @topics = Topic.where(:created_at.gt=>@from_time).and(:created_at.lt=>@to_time)
    @userlogs = UserLog.where(:created_at.gt=>@from_time).and(:created_at.lt=>@to_time).and(:action=>"FOLLOW_USER")
    @answers = Answer.where(:created_at.gt=>@from_time).and(:created_at.lt=>@to_time)
    @comments = Comment.where(:created_at.gt=>@from_time).and(:created_at.lt=>@to_time)
    
    @users = User.where(:created_at.gt=>@from_time).and(:created_at.lt=>@to_time)
  end
end