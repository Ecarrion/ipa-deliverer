class Project < ActiveRecord::Base

	mount_uploader :ipa, IpaUploader
 	attr_accessible :ipa, :name
end
