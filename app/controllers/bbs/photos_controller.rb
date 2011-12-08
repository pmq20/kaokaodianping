# coding: utf-8  
class Bbs::PhotosController < BbsController
  before_filter :require_user, :only => [:tiny_new,:new,:edit,:create,:update,:destroy]
  # GET /photos
  # GET /photos.xml
  def index
    @photos = LandPhoto.all
  end

  # GET /photos/1
  # GET /photos/1.xml
  def show
    @photo = LandPhoto.find(params[:id])
  end
  
  # GET /photos/new
  # GET /photos/new.xml
  def tiny_new
    @photo = LandPhoto.new
    render :layout => "bbs_window"
  end

  # GET /photos/new
  # GET /photos/new.xml
  def new
    @photo = LandPhoto.new
  end

  # GET /photos/1/edit
  def edit
    @photo = LandPhoto.find(params[:id])
    if @photo.user_id != current_user.id
      render_404
    end
  end

  # POST /photos
  # POST /photos.xml
  def create
    # 浮动窗口上传    
    if params[:tiny] == '1'
      photos = []
      if !params[:image1].blank?
        photo1 = LandPhoto.new
        photo1.image = params[:image1]
        photos << photo1
      end
      if !params[:image2].blank?
        photo2 = LandPhoto.new
        photo2.image = params[:image2]
        photos << photo2
      end
      if !params[:image3].blank?
        photo3 = LandPhoto.new
        photo3.image = params[:image3]
        photos << photo3
      end
    
      @photos = []
      photos.each  do |p|
        p.user_id = current_user.id
        if not p.save
          redirect_to(tiny_new_bbs_photos_path, :notice => p.errors.full_messages.join("<br />"))
          return
        else
          @photos << p
        end
      end
      render :action => :create, :layout => "bbs_window"
    else
      # 普通上传
      @photo = LandPhoto.new(params[:land_photo])
      if @photo.save
        redirect_to([:bbs,@photo], :notice => 'LandPhoto was successfully created.')
      else
        return render :action => "new"
      end
    end 
  end

  # PUT /photos/1
  # PUT /photos/1.xml
  def update
    @photo = LandPhoto.find(params[:id])
    if @photo.user_id != current_user.id
      render_404
    end
    if @photo.update_attributes(params[:land_photo])
      redirect_to([:bbs,@photo], :notice => 'LandPhoto was successfully updated.')
    else
      render :action => "edit"
    end
  end

  # DELETE /photos/1
  # DELETE /photos/1.xml
  def destroy
    @photo = LandPhoto.find(params[:id])
    if @photo.user_id != current_user.id
      render_404
    end
    @photo.destroy

    redirect_to(bbs_photos_url)
  end
end
