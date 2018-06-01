class Video < ActiveRecord::Base
	has_many :chunks, :foreign_key => 'vid_id', :class_name => 'Chunk', :dependent => :destroy
	validates :name, presence: true
	validates :file, presence: true
	  mount_uploader :file, VideoUploader
end
