require "resque"
class BaseMailer < ActionMailer::Base
#Pan>
#the following line is critical for the assyncronous sending of mails
#with this line, mails are sent through Resque, which can be inspected via /cpanel/resque
#without, the mails are sended directly, with the risk of hindering the request and errors.
  include Resque::Mailer
  default :from => Setting.email_sender
  helper :application,:users,:asks
  layout "mailer"

  def self.deliver_delayed(mail)
    begin
      user = User.where(email:mail.to[0].downcase).first
      if user
        user.current_mails ||= []
        user.current_mails << [mail.subject.to_s,mail.body.to_s]
        user.save!
      else
        mail.deliver
      end
    rescue Exception=>e
      p e
    end
  end

end
