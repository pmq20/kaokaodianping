module PsvrHelper
  def pos_signature0
    params[:controller].parameterize
  end
  
  def pos_signature
    "#{params[:controller].parameterize}_#{params[:action].parameterize}"
  end
  
  def pos_bbs?
    pos_signature0.starts_with?('bbs-')
  end
  
end