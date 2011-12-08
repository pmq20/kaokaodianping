class Cpanel::AutofollowController < CpanelController
  def index
    @users = User.where(:will_autofollow.ne=>nil)
    @topics = Topic.where(:will_autofollow.ne=>nil)
    @asks = Ask.where(:will_autofollow.ne=>nil)
  end
end