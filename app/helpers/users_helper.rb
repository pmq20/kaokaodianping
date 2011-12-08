# coding: utf-8
module UsersHelper
  def user_path2(user)
    if user.slug
      slug = user.slug.split('.').join('_')
    else
      slug = user.name
    end
    "/users/#{slug}"
  end

  def user_name_tag(user, options = {})
    options[:url] ||= false
    return "" if user.blank?
    return "匿名用户" if !user.deleted.blank?
    user.name=truncate(user.name,:length => 15, :truncate_string =>"")
    return user.name if user.slug.blank?
    user.slug= user.slug.split('.').join('_')
    url = "/users/#{user.slug}"#options[:url] == true ? user_url(user.slug) : user_path2(user)
    
    if options[:with_avatar]
      avaurl = user.avatar.small.url
      if avaurl.blank?
        avaurl = ''
      elsif "avatar/small.jpg"==avaurl
        avaurl="avatar/small_trans.jpg"
      end
      unless avaurl.starts_with?('/uploads/')
        avaurl = '/images/'+avaurl
      end
      style = "background: transparent url(#{avaurl}) no-repeat scroll 0 7px"
    else
      style = ''
    end
    raw "<a style=\"#{style}\" #{options[:is_notify] == true ? " onclick=\"mark_notifies_as_read_one(this, '#{options[:notify].id}');\"" : ""} href=\"#{url}\" class=\"user #{' usernameV ' if user.is_expert} #{' with_avatar ' if options[:with_avatar]}\" title=\"#{h(user.name)}\">#{h(user.name)}</a>"
  end
  
  def user_avatar_tag(user,size,opts = {})
    size2 = opts[:size2] || nil
    link = opts[:link] || true
    return "" if user.blank?
    return "" if user.slug.blank?
    url = eval("user.avatar.#{size}.url")
    if url.blank?
      url = ''
    end
    if user.deleted.blank?
      img = "#{(size2)?(image_tag(url, :style => 'width:'+size2.to_s+'px;height:'+size2.to_s+'px')):(image_tag(url, :class => size))}"
      if link
        raw "<a href=\"#{user_path2(user)}\" class=\"user\" title=\"#{h(user.name)}\">#{img}</a>" #,:alt=>user.name
      else
        raw img
      end
    else
      if size2
        mid=image_tag(url, :style => 'width:'+size2.to_s+'px;height:'+size2.to_s+'px') #,:alt=>user.name
      else
        mid=image_tag(url, :class => size.to_s) #,:alt=>user.name
      end
      if link
        raw "<a href=\"#\" class=\"user\">"+mid+"</a>"
      else
        raw mid
      end
    end
  end

  def user_tagline_tag(user,options = {})
    return "" if user.blank?
    prefix = options[:prefix] || ""
    return "" if user.tagline.blank?
    raw "#{prefix}#{h(truncate(user.tagline, :length => 30))}"
  end

  def user_sex_title(user,current_user=nil)
    return "" if user.blank?
    user.girl.blank? == true ? "他" : "她"
    return "我" if current_user
    "他"
  end

  # 支持者列表
  def up_voter_links(up_voters, options = {})
    limit = options[:limit] || 3
    links = []
    hide_links = []
    up_voters.each_with_index do |u,i|
      link = user_name_tag(u)
      if i <= limit
        links << link
      else
        hide_links << link
      end
    end
    html = "<span class=\"voters\">#{links.join(",")}"
    if !hide_links.blank?
      html += "<a href=\"#\" onclick=\"$(this).next().show();$(this).replaceWith(',');return false;\" class=\"more\">(更多)</a><span class=\"hidden\">#{hide_links.join(",")}</span>"
    end
    html += "</span>"
    raw html
  end
end
