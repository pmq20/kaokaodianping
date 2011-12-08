# coding: utf-8

module TagsHelper
  def tags_more_criterion(more)
    if more and !more.empty?
      ret="且同时是"
      more.each_with_index do |item,i|
        ret+=link_to(item,"/tags/#{item}",style:'color:green')
        ret+='、' unless i==more.size-1
      end
      ret += '的'
      ret.html_safe
    end
  end
end
