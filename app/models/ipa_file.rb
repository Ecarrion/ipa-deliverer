class IpaFile < ActiveRecord::Base
  # attr_accessible :title, :body

  def self.save(upload)

  	name = upload['ipafile'].original_filename
  	directory = "public/data"

	#create the file path
	path = File.join(directory, name)

	#write the file
	File.open(path, "wb") { |file| file.write(upload['ipafile'].read) }

  end

end
