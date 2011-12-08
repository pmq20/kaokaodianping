# coding: utf-8  
class Bbs::Cpanel::SectionsController < Bbs::Cpanel::ApplicationController
  # GET /sections
  # GET /sections.xml
  def index
    @sections = LandSection.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sections }
    end
  end

  # GET /sections/1
  # GET /sections/1.xml
  def show
    @section = LandSection.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @section }
    end
  end

  # GET /sections/new
  # GET /sections/new.xml
  def new
    @section = LandSection.new    

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @section }
    end
  end

  # GET /sections/1/edit
  def edit
    @section = LandSection.find(params[:id])
  end

  # POST /sections
  # POST /sections.xml
  def create
    @section = LandSection.new(params[:land_section])

    respond_to do |format|
      if @section.save
        format.html { redirect_to(bbs_cpanel_sections_path, :notice => 'LandSection was successfully created.') }
        format.xml  { render :xml => @section, :status => :created, :location => @section }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @section.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /sections/1
  # PUT /sections/1.xml
  def update
    @section = LandSection.find(params[:id])

    respond_to do |format|
      if @section.update_attributes(params[:land_section])
        format.html { redirect_to(bbs_cpanel_sections_path, :notice => 'LandSection was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @section.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /sections/1
  # DELETE /sections/1.xml
  def destroy
    @section = LandSection.find(params[:id])
    @section.destroy

    respond_to do |format|
      format.html { redirect_to(bbs_cpanel_sections_url) }
      format.xml  { head :ok }
    end
  end
end
