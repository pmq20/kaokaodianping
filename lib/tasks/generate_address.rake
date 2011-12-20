# coding: utf-8
namespace :generate do
  task :address=>:environment do
    Ask.all.each do |ask|
if ask.type and ask.body
  aa=Nokogiri.HTML(ask.body).text()
  a=aa.split("地址")[-1]
  if a
    addr = a.split("\n")[0]
    addr = addr[1..-1] if addr.starts_with?("：")
    addr = addr[1..-1] if addr.starts_with?(":")
    addr = addr[5..-1] if addr.starts_with? "地  址："
    addr = addr[3..-1] if addr.starts_with? "地点："
    addr = addr[4..-1] if addr.starts_with? "地 址："
    addr = addr.split('电话')[0]
    addr = addr.split('(')[0]
    addr = addr.split('（')[0]
    addr = addr[0..-2] if addr.ends_with? "。"
    addr = addr.strip
    ask.address=addr
ask.geocode
    ask.save!
  end
end
end
end
end
