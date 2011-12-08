class ReportSpam
  include Mongoid::Document
  include Mongoid::Timestamps


  field :url
  field :descriptions, :type => Array, :default => []

  index :url
validates_presence_of :descriptions

  def self.add(url, description, user_name)
    report = find_or_create_by(:url => url)
    report.descriptions << "#{user_name}:\n#{description}"
    report.save
  end
  include BaseModel
end
