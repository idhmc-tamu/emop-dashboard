# Describes an eMOP font
#
class Font < ActiveRecord::Base
  self.primary_key = :font_id
  has_many :batch_jobs

  validates :font_name, presence: true

  def file
    path
  end

  def file=(val)
    if Settings.emop_font_dir
      self.path = File.join(Settings.emop_font_dir, "#{self.font_name}#{Settings.font_suffix}")
      File.open(self.path, 'wb') { |f| f.write(val.read) }
    end
  end

  def to_builder(version = 'v1')
    case version
    when 'v1'
      Jbuilder.new do |json|
        json.id                 id
        json.font_name          font_name
        json.font_italic        font_italic
        json.font_bold          font_bold
        json.font_fixed         font_fixed
        json.font_serif         font_serif
        json.font_fraktur       font_fraktur
        json.font_line_height   font_line_height
        json.font_library_path  font_library_path
      end
    when 'v2'
      Jbuilder.new do |json|
        json.id                 id
        json.font_name          font_name
        json.font_italic        font_italic
        json.font_bold          font_bold
        json.font_fixed         font_fixed
        json.font_serif         font_serif
        json.font_fraktur       font_fraktur
        json.font_line_height   font_line_height
        json.font_library_path  font_library_path
        json.path               path
      end
    end
  end

  #TODO: Remove once schema is sane
  def id
    read_attribute(:font_id)
  end

  #TODO: Remove once schema is sane
  def name
    read_attribute(:font_name)
  end

  def traineddata_path
    File.join(Rails.application.secrets.emop_font_dir, "#{self.font_name}#{Settings.font_suffix}")
  end
end
