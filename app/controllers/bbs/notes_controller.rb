# coding: utf-8  
class Bbs::NotesController < BbsController
  before_filter :require_user, :except => [:show]
  # GET /notes
  # GET /notes.xml
  def index
    @notes = current_user.notes.paginate(:page => params[:page], :per_page => 20)
    set_seo_meta("记事本")
  end

  # GET /notes/1
  # GET /notes/1.xml
  def show
    @note =  LandNote.find(params[:id])
    if not @note.publish 
      if current_user.blank? or @note.user_id != current_user.id
        render_404 and return
      end
    end
    set_seo_meta("查看 &raquo; 记事本")
  end

  # GET /notes/new
  # GET /notes/new.xml
  def new
    @note = LandNote.new
    set_seo_meta("新建 &raquo; 记事本")
  end

  # GET /notes/1/edit
  def edit
    @note = LandNote.find(params[:id])
    set_seo_meta("修改 &raquo; 记事本")
  end

  # POST /notes
  # POST /notes.xml
  def create
    @note = current_user.notes.new(params[:land_note])  

    if @note.save
      redirect_to([:bbs,@note], :notice => '创建成功。')
    else
      render :action => "new"
    end
  end

  # PUT /notes/1
  # PUT /notes/1.xml
  def update
    @note = LandNote.find(params[:id])
    if @note.user_id != current_user.id
      render_404
    end

    if @note.update_attributes(params[:land_note])
      redirect_to([:bbs,@note], :notice => '修改成功。')
    else
      render :action => "edit"
    end
  end

  # DELETE /notes/1
  # DELETE /notes/1.xml
  def destroy
    @note = LandNote.find(params[:id])
    if @note.user_id != current_user.id
      render_404
    end
    @note.destroy

    redirect_to(bbs_notes_url)
  end
end
