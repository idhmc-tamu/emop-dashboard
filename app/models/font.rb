
# Describes an eMOP font 
#
class Font < ActiveRecord::Base
   establish_connection(:emop)
   self.table_name = :fonts
   self.primary_key = :font_id   
   has_many :batch_jobs, foreign_key: 'font_id'
end