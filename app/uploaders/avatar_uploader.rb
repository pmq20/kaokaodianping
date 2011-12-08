class AvatarUploader < BaseUploader
  def default_url
    "avatar/#{version_name}.jpg"
  end

  version :small do
    process :resize_to_fill => [25,25]
  end
  
  version :normal do
    process :resize_to_fill => [64,64]
  end
  
  version :big do
    process :resize_to_fill => [100,100]
  end
  
  
  
  version :bbs_normal do
    process :resize_to_fill => [48,48]
  end
  version :bbs_small do
    process :resize_to_fill => [16,16]
  end
  version :bbs_large do
    process :resize_to_fill => [80,80]
  end
end
