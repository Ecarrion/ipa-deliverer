require 'fileutils'
require 'zip/zip'
require 'cfpropertylist'

class Project < ActiveRecord::Base

	mount_uploader :ipa, IpaUploader
 	attr_accessible :ipa, :name
 	
 	def create_plist_in_url(url)
 	  
 	  #Unzip ipa content in desired path
 	  ipaPath = "public#{self.ipa}"
 	  unzippedPath = "public/uploads/project/ipa/#{self.id}"
 	  unzip_file(ipaPath, unzippedPath)
 	  
 	  #Search for a *.app file
 	  appName = ""
 	  Dir.foreach("#{unzippedPath}/Payload") do |fname|
 	    ext = File.extname(fname)
 	    if ext == ".app"
 	      appName = fname
 	      break;
 	    end
    end
 	  
 	  #Read propper plist info from ipa
 	  infoPlistPath = "#{unzippedPath}/Payload/#{appName}/Info.plist"
 	  plistObject = CFPropertyList::List.new
 	  plistObject = CFPropertyList::List.new(:file => infoPlistPath)
 	  infoPlist = CFPropertyList.native_types(plistObject.value)
 	  
 	  #Delete Unzipped content
    FileUtils.rm_rf("#{unzippedPath}/Payload")
 	  
 	  #Create new plist to download
 	  uploadInfo = Hash.new
 	  uploadInfo['kind'] = 'software-package'
 	  uploadInfo['url'] = "#{url}#{self.ipa}"
 	  assetsArray = [uploadInfo]
 	  
 	  ipaInfo = Hash.new
 	  ipaInfo['bundle-identifier'] = infoPlist['CFBundleIdentifier']
 	  ipaInfo['bundle-version'] = infoPlist['CFBundleVersion']
 	  ipaInfo['kind'] = 'software'
 	  ipaInfo['title'] = infoPlist['CFBundleName'];
 	  
 	  itemsArray = [{'assets' => assetsArray, 'metadata' => ipaInfo}]
 	  plistDic = {'items' => itemsArray}
 	  
 	  plistPath = "#{ipaPath}.plist"
 	  plistObject = CFPropertyList::List.new
 	  plistObject.value = CFPropertyList.guess(plistDic)
 	  plistObject.save(plistPath, CFPropertyList::List::FORMAT_XML)
 	  
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