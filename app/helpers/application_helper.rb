# coding: utf-8
module ApplicationHelper
  def tt(path)
    I18n.t('t2ku.'+path)
  end

  def title_for_this_page
    case controller.controller_name
    when 'logs'
    '考考点评正在发生:'
    else
    '我的首页:'
    end
  end

  def v_icon(user)
    if user and user.is_expert
      user.is_expert_why ||=''
      ('<div class="verifyLogo" title="'+user.is_expert_why+'">&nbsp;&nbsp;&nbsp;</div>').html_safe
    else
      ''
    end
  end

  def use_yahei_font?(ua)
    use = true
    ["Windows NT 5.2", "Windows NT 5.1"].each do |w|
      if ua.include?(w)
        use = false
        break
      end
    end
    return use
  end
  
  def ask_notification_tag(ask_id, notify, show_ask = true)
    return if ask_id.nil?
    
    log = notify.log
    a = notify.action
    tag = ""
    ask = Ask.first(:conditions => {:id => ask_id})
    return "" if ask.blank? or log.blank? or log.user.blank?
    # ask_tag = "<a href=\"#{ask_path(ask)}\">#{ask.title}</a>"
    user_tag = "<a href=\"/users/#{log.user.slug}\">#{log.user.name}</a> "
    
    case a
    when "AGREE_ANSWER", "NEW_ANSWER_COMMENT"
      tag += user_tag + " #{a == "AGREE_ANSWER" ? "赞成" : "评论"}了你在"
      ask_tag = "<a onclick=\"mark_notifies_as_read_one(this, '#{notify.id}');\" href=\"#{ask_path(ask)}#{a == "AGREE_ANSWER" ? "#answer_" + log.target_id.to_s : "?eawc=yes&awid=" + log.title.to_s + "#answer_" + log.title.to_s}\">#{show_ask ? ask.title : "中的点评。"}</a>" + (show_ask ? " 中的点评。" : "")
      tag += (show_ask ? "点评 " : "") + ask_tag
    when "NEW_ANSWER", "NEW_ASK_COMMENT"
      tag += user_tag + " #{a == "NEW_ANSWER" ? ask.tianjia_what : "评论"}了"
      ask_tag = "<a onclick=\"mark_notifies_as_read_one(this, '#{notify.id}');\" href=\"#{ask_path(ask)}#{a == "NEW_ASK_COMMENT" ? "?easc=yes&asid=" + log.target_parent_id.to_s : ""}#answer_#{log.target_id.to_s}\">#{show_ask ? ask.title : "该点评。"}</a>"
      tag += (show_ask ? "#{ask.typewhat} " : "") + ask_tag
    when "THANK_ANSWER"
      tag += user_tag + "感谢了你"
      if show_ask
        ask_tag = "在 <a onclick=\"mark_notifies_as_read_one(this, '#{notify.id}');\" href=\"#{ask_path(ask)}?nr=1#answer_#{log.target_id.to_s}\">#{ask.title}</a> 的点评。"
      else
        ask_tag = "的点评。"
      end
      tag += ask_tag
    when "INVITE_TO_ANSWER"
      tag += user_tag + "邀请你点评 "
      if show_ask
        tag += "<a onclick=\"mark_notifies_as_read_one(this, '#{notify.id}');\" href=\"#{ask_path(ask)}?nr=1\">#{ask.title}</a>"
      end
    when "ASK_USER"
      tag += user_tag + "向你询问 "
      if show_ask
        tag += "<a onclick=\"mark_notifies_as_read_one(this, '#{notify.id}');\" href=\"#{ask_path(ask)}?nr=1\">#{ask.title}</a>"
      end
    end
    return tag
  end
  
  def admin?(user)
    return true if Setting.admin_emails.index(user.email)
    return false
  end
  
  def owner?(item)
    return false if current_user.blank?
    return false if !item.respond_to?(:user_id) 
    if item.user_id == current_user.id
      return true
    end
    return false
  end

  # 可信用户，管理员，Owner 可以
  def can_edit?(item)
    return false if current_user.blank?
    
    return true if owner?(item)
    return true if current_user.credible == true or admin?(current_user)
    false
  end

  def auto_link_urls(text, href_options = {}, options = {})
    extra_options = tag_options(href_options.stringify_keys) || ""
    limit = options[:limit] || nil
    text.gsub(AUTO_LINK_RE) do
      all, a, b, c = $&, $1, $2, $3
      if a =~ /<a\s/i # don't replace URL's that are already linked
        all
      else
        begin
          text = b + c
        rescue => e
          Rails.logger.warn { "auto_link_urls faield text = b + c" }
        end

        text = yield(text) if block_given?
        if(not limit.blank?)
          text = truncate(text, :length => limit)
        end
        %(#{a}<a href="#{b=="www."?"http://www.":b}#{c}"#{extra_options}>#{text}</a>)
      end
    end
  end

    AUTO_LINK_RE = %r{
                        (                          # leading text
                          <\w+.*?>|                # leading HTML tag, or
                          [^=!:'"/]|               # leading punctuation, or 
                          ^                        # beginning of line
                        )
                        (
                          (?:https?://)|           # protocol spec, or
                          (?:www\.)                # www.*
                        ) 
                        (
                          [-0-9A-Za-z_]+           # subdomain or domain
                          (?:\.[-0-9A-Za-z_]+)*    # remaining subdomains or domain
                          (?::\d+)?                # port
                          (?:/(?:(?:[~0-9A-Za-z_\+%-]|(?:[,.;:][^\s$]))+)?)* # path
                          (?:\?[0-9A-Za-z_\+%&=.;-]+)?     # query string
                          (?:\#[0-9A-Za-z_\-]*)?   # trailing anchor
                        )
  }x unless const_defined?(:AUTO_LINK_RE)

  # form auth token
  def auth_token
    raw "<input name=\"authenticity_token\" type=\"hidden\" value=\"#{form_authenticity_token}\" />"
  end
  
  # 去除区域里面的内容的换行标记  
  def spaceless(&block)
    data = with_output_buffer(&block)
    data = data.gsub(/\n\s+/," ")
    data = data.gsub(/>\s+</,"> <")
    raw data
  end
  
end
