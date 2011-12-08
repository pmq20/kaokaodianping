# coding: utf-8  
class Bbs::Cpanel::PhotosController < Bbs::Cpanel::ApplicationController
  # GET /photos
  # GET /photos.xml
  def index
    @photos = LandPhoto.desc("id").paginate :page => params[:page], :per_page => 20
  end

  # GET /photos/1
  # GET /photos/1.xml
  def show
    @photo = LandPhoto.find(params[:id])
  end

  # GET /photos/new
  # GET /photos/new.xml
  def new
    @photo = LandPhoto.new
  end

  # GET /photos/1/edit
  def edit
    @photo = LandPhoto.find(params[:id])
  end

  # POST /photos
  # POST /photos.xml
  def create
    @photo = LandPhoto.new(params[:land_photo])
    @photo.user_id = current_user.id
    if @photo.save
      redirect_to(bbs_cpanel_photo_path(@photo), :notice => 'LandPhoto was successfully created.')
    else
      render :action => "new"
    end
  end

  # PUT /photos/1
  # PUT /photos/1.xml
  def update
    @photo = LandPhoto.find(params[:id])
    if @photo.update_attributes(params[:land_photo])
      redirect_to(bbs_cpanel_photo_path(@photo), :notice => 'LandPhoto was successfully updated.')
    else
      render :action => "edit"
    end
  end

  # DELETE /photos/1
  # DELETE /photos/1.xml
  def destroy
    @photo = LandPhoto.find(params[:id])
    @photo.destroy

    redirect_to(bbs_cpanel_photos_url)
  end
end
