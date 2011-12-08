# coding: utf-8
module MoreHelper
  def gap(time)
    secs = Time.now - time

    if secs<=60
      return "#{secs.to_i}秒"
    elsif secs<=60*60
      return "#{(secs/60).to_i}分钟"
    elsif secs<=60*60*24
      return "#{(secs/3600).to_i}小时"
    elsif secs<=60*60*24*30
      return "#{(secs/(3600*24)).to_i}天"
    elsif secs<=60*60*24*30*12
      return "#{(secs/(3600*24*30)).to_i}个月"
    else
      return "#{(secs/(3600*24*30*12)).to_i}年"
    end
  end
end