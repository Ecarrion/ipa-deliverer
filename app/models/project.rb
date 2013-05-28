require 'fileutils'

class Project < ActiveRecord::Base

	mount_uploader :ipa, IpaUploader
 	attr_accessible :ipa, :name
 	
 	def create_plist_in_url(url)
 	  
 	  uploadInfo = Hash.new
 	  uploadInfo['kind'] = 'software-package'
 	  uploadInfo['url'] = "#{url}#{self.ipa}"
 	  assetsArray = [uploadInfo]
 	  
 	  ipaInfo = Hash.new
 	  ipaInfo['bundle-identifier'] = 'com.hp.Snapfish'
 	  ipaInfo['bundle-version'] = '1.6'
 	  ipaInfo['kind'] = 'software'
 	  ipaInfo['title'] = 'Snapfish'
 	  
 	  itemsArray = [{'assets' => assetsArray, 'metadata' => ipaInfo}]
 	  plistDic = {'items' => itemsArray}
 	  
 	  path = "public#{self.ipa}.plist"
 	  File.open(path, 'w') {|f| f.write(plistDic.to_plist)}
  end
  
  def delete_ipa_files
    path = "public/uploads/project/ipa/#{self.id}"
    FileUtils.rm_rf(path)
  end
 	
end