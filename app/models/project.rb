require 'fileutils'
require 'zip/zip'

class Project < ActiveRecord::Base

	mount_uploader :ipa, IpaUploader
 	attr_accessible :ipa, :name
 	
 	def create_plist_in_url(url)
 	  
 	    ipaPath = "public#{self.ipa}"
 	    unzip_file(ipaPath, "unzipped")
 	  
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
 	  
 	    plistPath = "#{ipaPath}.plist"
 	    File.open(plistPath, 'w') {|f| f.write(plistDic.to_plist)}
 	    return true
  end
  
  def delete_ipa_files
    path = "public/uploads/project/ipa/#{self.id}"
    FileUtils.rm_rf(path)
  end
  
  def unzip_file (file, destination)
    Zip::ZipFile.open(file) { |zip_file|
     zip_file.each { |f|
       f_path=File.join(destination, f.name)
       FileUtils.mkdir_p(File.dirname(f_path))
       zip_file.extract(f, f_path) unless File.exist?(f_path)
     }
    }
  end
 	
end