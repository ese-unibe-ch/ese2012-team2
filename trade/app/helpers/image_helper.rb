
class ImageHelper

  #PS saves the image and return the filename
  def self.save image, target_folder
    filename = nil

    unless image.nil?
      if self.image? image
        until self.is_unique(filename, target_folder) do
          #PS potential eternal loop...
          filename = self.generate_filename image
        end

        File.open("#{target_folder}/#{filename}", "w") do |file|
          file.write(image[:tempfile].read)
          #PS only activate resize if you have ImageMagick installed and PATH setup correctly
          #self.resize(file)
        end
      end
    end
    filename
  end

  def self.image? image
    puts image[:filename]
    mime_type =  MIME::Types.type_for(image[:filename], false)
    mime_type[0].media_type == 'image'
  end

  def self.resize(file)
    image = MiniMagick::Image.new(file.path)
    image.resize "150x150"
  end

  def self.generate_filename image
    "#{Digest::MD5.hexdigest(image[:filename] + Time.now.to_s)}.#{image[:filename].split(".").last()}"
  end

  def self.is_unique filename, public_folder
      !filename.nil? and !File.exist? "#{public_folder}/images/items/#{filename}"
  end
end