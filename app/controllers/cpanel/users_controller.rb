# coding: UTF-8
class Cpanel::UsersController < CpanelController

  def index
        params[:q] = params[:q].strip if params[:q]
    @users = User
    @users = @users.any_of({:name=>Regexp.new(params[:q])},{:email=>params[:q]},{:slug=>params[:q]}) if params[:q]
    @users = @users.where(:tags => params[:tag]) if params[:tag]
    @users = @users.where(:is_expert.ne=>nil) if params[:is_expert]
    @users = @users.desc(params[:sort]) if params[:sort]
    @users = @users.desc("created_at").paginate(:page => params[:page], :per_page => 20)
@tags = User.all.to_a.inject([]){|s,i| if i.tags;s+i.tags;else;[];end}
if @tags
  @tags = @tags.uniq
else
  @tags = []
end

    respond_to do |format|
      format.html # index.html.erb
      format.json
    end
  end

  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json
    end
  end
  
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json
    end
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to(cpanel_users_path, :notice => 'User 创建成功。') }
        format.json
      else
        format.html { render :action => "new" }
        format.json
      end
    end
  end
  
  def update
    @user = User.find(params[:id])
    
    respond_to do |format|
      @user.tags_array = params[:user][:tags_array]
      if @user.update_attributes(params[:user])
        format.html { redirect_to(cpanel_users_path, :notice => 'User 更新成功。') }
        format.json
      else
        format.html { render :action => "edit" }
        format.json
      end
    end
  end
  
  def destroy
    @user = User.find(params[:id])
    @user.soft_delete

    respond_to do |format|
      format.html { redirect_to(cpanel_users_path,:notice => "删除成功。") }
      format.json
    end
  end
end
