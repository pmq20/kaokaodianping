# coding: utf-8
require 'digest/md5'
require 'net/http'
require 'uri'
class ApplicationController < ActionController::Base
  protect_from_forgery
  helper :all
  before_filter :init, :load_notice

  def force_utf8_things
    # force_encoding = lambda do |o|
    #   o.force_encoding(Encoding::UTF_8) if o.respond_to?(:force_encoding)
    # end
    ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
    iconv = lambda do |o|
      o = ic.iconv(o + ' ')[0..-2]
    end
    psvr_traverse(params, iconv)
  end
  
  #before_filter :force_utf8_things

before_filter Proc.new{
  if user_signed_in?
    if current_user.banished and current_user.banished=="1"
      render file:'shared/banished' and return
    end
  end
}
before_filter Proc.new{
  params[:page]=0 if ''==params[:page]
} 
#PSVR>
#[TODO] don't let mobile users see zheye
 # has_mobile_fu

before_filter :bao10jie_filter
before_filter :check_browser
before_filter :login_reg
def login_reg
  if !user_signed_in?
    @new_user = User.new 
  end
end

def after_sign_in_path_for(resource_or_scope)
  if params[:redirect_to].blank?
    super(resource_or_scope)
  elsif '/'==params[:redirect_to]
    doing_path
  else
    params[:redirect_to]
  end
end

def check_browser
  @is_ie = (request.env['HTTP_USER_AGENT'].downcase.index('msie')!=nil)
  @is_ie6 = (request.env['HTTP_USER_AGENT'].downcase.index('msie 6')!=nil)
  @is_ie7 = (request.env['HTTP_USER_AGENT'].downcase.index('msie 7')!=nil)
end
def bugtrack
  redirect_to '/asks/4ea0de69d1212f2c4d000006'
  return
end
  def init
    if params[:force_format] == "mobile"
      cookies[:mobile] = true
    elsif params[:force_format] == "desktop"
      cookies[:mobile] = nil
    end

    if !cookies[:mobile].blank? and request.format.to_sym == :html
      force_mobile_format
    end
  end

  def load_notice
    @notice = Notice.last
    if !@notice.blank? and !@notice.end_at.blank?
      if @notice.end_at < Time.now
        @notice = nil
      end
    end
  end
  
  # 暂时不使用mobile-fu的功能，仅仅使用其is_mobile_device?方法
  #include ActionController::MobileFu::InstanceMethods
  #helper_method :is_mobile_device?
  
  # Comet Server
  use_zomet
def nb
@follower=User.first
@invitors=[User.first]
@ask=Ask.where(type:nil).first
@answer=Answer.first
@user=User.first
  render file:"/user_mailer/#{params[:file]}",:layout=>'tmp'
end
  # set page title, meta keywords, meta description
  def set_seo_meta(title, options = {})
    keywords = options[:keywords] || ""
    description = options[:description] || ""

    if title.length > 0
      @page_title = "#{title} &raquo; "
    end
    @meta_keywords = keywords
    @meta_description = description
  end

  def render_404
    render_optional_error_file(404)
  end

  def render_optional_error_file(status_code)
    @render_no_sidebar=true
    status = status_code.to_s
    if ["404", "422", "500"].include?(status)
      render :template => "/errors/#{status}.html.erb", :status => status, :layout => "application"
    else
      render :template => "/errors/unknown.html.erb", :status => status, :layout => "application"
    end
  end
  
  def store_location
    session[:return_to] = request.request_uri
  end
  
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def require_user(options = {})
    format = options[:format] || :html
    format = format.to_s
    if format == "html"
      authenticate_user!
    elsif format == "json"
      if current_user.blank?
        render :json => { :success => false, :msg => "你还没有登陆。" }
        return false
      end
    elsif format == "text"
      # Ajax 调用的时候如果没有登陆，那直接返回 nologin，前段自动处理
      if current_user.blank?
        render :text => "_nologin_" 
        return false
      end
    elsif format == "js"
      if current_user.blank?
        render :text => "location.href = '/login';"
        return false
      end
    end
    true
  end


  def require_user_json
    require_user(:format => :json)
  end

  def require_user_js
    require_user(:format => :js)
  end

  def require_user_text
    require_user(:format => :text)
  end
  
  def tag_options(options, escape = true)
    unless options.blank?
      attrs = []
      options.each_pair do |key, value|
        if BOOLEAN_ATTRIBUTES.include?(key)
          attrs << %(#{key}="#{key}") if value
        elsif !value.nil?
          final_value = value.is_a?(Array) ? value.join(" ") : value
          final_value = html_escape(final_value) if escape
          attrs << %(#{key}="#{final_value}")
        end
      end
      " #{attrs.sort * ' '}".html_safe unless attrs.empty?
    end
  end
  
  def tag(name, options = nil, open = false, escape = true)
    "<#{name}#{tag_options(options, escape) if options}#{open ? ">" : " />"}".html_safe
  end
  
  def simple_format(text, html_options={}, options={})
    text = ''.html_safe if text.nil?
    start_tag = tag('p', html_options, true)
    text.gsub!(/\r\n?/, "\n")                    # \r\n and \r -> \n
    text.gsub!(/\n\n+/, "</p><br />#{start_tag}")  # 2+ newline  -> paragraph
    text.gsub!(/([^\n]\n)(?=[^\n])/, '\1<br />') # 1 newline   -> br
    text.insert 0, start_tag
    text.html_safe.safe_concat("</p>")
  end

  #def authenticate_user!(force=false)
  #  warden.authenticate!(:scope => :user) if !devise_controller? || force
  #end
  #
  #
  
protected
  def psvr_traverse(object, block)
    if object.kind_of?(Hash)
      object.each_value { |o| psvr_traverse(o, block) }
    elsif object.kind_of?(Array)
      object.each { |o| psvr_traverse(o, block) }
    else
      block.call(object)
    end
    object
  end

  def bao10jie_sig(canshu)
    canshu
    canshu_a  = canshu.sort
    pinjie = []
    canshu_a.each do |item|
      pinjie << "#{item[0]}=#{item[1]}"
    end
    pinjie = pinjie.join('&')
    pinjie+=Bao10jie::Config::APP_KEY
    Digest::MD5.hexdigest(pinjie)
  end

  def bao10jie_filter
    return true if request.method=='GET'
    # iconv = Proc.new{ |o|
    #   if o.
    # }
    # 
    # lambda do |o|
    #   o = ic.iconv(o + ' ')[0..-2]
    # end
    # psvr_traverse(params, iconv)
  end
end
