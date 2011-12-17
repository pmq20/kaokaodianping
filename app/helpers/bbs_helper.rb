# coding: utf-8  
require "bluecloth"
require "digest/md5"
module BbsHelper
#def notice_message
#def markdown(str)
#def timeago(time, options = {})
#def will_paginate1(pages)
#def format_topic_body(text,title = "",allow_image = true)
#def topic_use_readed_text(state)
#def bbs_user_name_tag(user,options = {})

  # return the formatted flash[:notice] html
  def notice_message()
    if flash[:notice]
      result = '<div class="alert-message success"><a href="#" class="close">x</a>'+flash[:notice]+'</div>'
    elsif flash[:warring]
        result = '<div class="alert-message warring"><a href="#" class="close">x</a>'+flash[:warring]+'</div>'
    elsif flash[:error]
        result = '<div class="alert-message error"><a href="#" class="close">x</a>'+flash[:error]+'</div>'
    else
      result = ''
    end
    
    return raw(result)
  end
  
  def markdown(str)
    raw "<div class=\"markdown_content\">#{BlueCloth.new(str).to_html}</div>"
  end
    
  def timeago(time, options = {})
    options[:class] ||= "timeago"
    content_tag(:abbr, time.to_s, options.merge(:title => time.getutc.iso8601)) if time
  end
  
  class BootstrapLinkRenderer < ::WillPaginate::ViewHelpers::LinkRenderer
    protected
    def html_container(html)
      tag :div, tag(:ul, html), container_attributes
    end

    def page_number(page)
      tag :li, link(page, page, :rel => rel_value(page)), :class =>
('active' if page == current_page)
    end

    def gap
      tag :li, link(super, '#'), :class => 'disabled'
    end

    def previous_or_next_page(page, text, classname)
      tag :li, link(text, page || '#'), :class => [classname[0..3],
classname, ('disabled' unless page)].join(' ')
    end
  end

  def will_paginate1(pages)
    will_paginate(pages, :class => 'pagination', :inner_window => 2,
:outer_window => 0, :renderer => BootstrapLinkRenderer, :previous_label =>
'上一页'.html_safe, :next_label => '下一页'.html_safe)
  end
  
  
  # topic
  def format_topic_body(text,title = "",allow_image = true)
    text.gsub!("\s","&nbsp;")
    text = simple_format(text)
    text.gsub!(/\[img\](.+?)\[\/img\]/i,'<img src="\1" alt="'+ h(title) +'" />')
    text = auto_link(text,:all, :target => '_blank', :rel => "nofollow")
    text.gsub!(/#([\d]+)楼&nbsp;/,raw('#<a href="#reply\1" class="at_floor" data-floor="\1" onclick="return Topics.hightlightReply(\1)">\1楼</a> '))
    text.gsub!(/@(.+?)&nbsp;/,raw('@<a href="http://twitter.com/\1" class="at_user" title="\1">\1</a> '))
    return raw(text)
  end

  def topic_use_readed_text(state)
    case state
    when 0
      "在你读过以后还没有新变化"
    else
      "有新内容"
    end
  end
  
  
  
  # user
  def bbs_user_name_tag(user,options = {})
    location = options[:location] || false
    return "匿名" if user.blank?
    result = "<a href=\"/users/#{user.slug}\" title=\"#{user.name}\">#{user.name}</a>"
    if location
      if !user.location.blank?
        result += " <span class=\"location\" title=\"门牌号\">[#{user.location}]</span>"
      end
    end
    raw(result)
  end
end
