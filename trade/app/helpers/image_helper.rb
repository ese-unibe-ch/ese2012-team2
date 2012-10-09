class ImageHelper

  #PS saves the image and return the filename
  def self.save image, public_folder
    filename = nil

    unless image.nil?
      #PS process and save image
      filename = Digest::MD5.hexdigest(image[:filename] + Time.now.to_s)  + "." + image[:filename].split(".").last()

      #PS TODO check if filename already exists and generate new filename
      #PS TODO check if file is an image
      File.open(public_folder + '/images/items/' + filename, "w") do |file|
        file.write(image[:tempfile].read)
        #PS TODO resize image
      end
    end
    filename
  end

  def self.image?

  end

  def self.resize(image)

  end
end