require 'cgi'
require 'open-uri'
require 'uri'

require 'RMagick'

require 'murlsh'

module Murlsh

  # Fetch images from urls and store them locally.
  class ImgStore

    def initialize(storage_dir, options={})
      @storage_dir = storage_dir
      @user_agent = options[:user_agent]
    end

    # Build headers to send with request.
    def headers
      result = {}
      result['User-Agent'] = @user_agent if @user_agent
      result
    end

    # Fetch an image from a url and store it locally.
    #
    # The filename will be the md5sum of the contents plus the original
    # extension.
    #
    # If a block is given the Magick::ImageList created will be yielded
    # before storage.
    def store_url(url, &block)
      open(url, headers) { |fin| store_img_data(fin.read, &block) }
    end

    # Accept a blob of image data and store it locally.
    #
    # The filename will be the md5sum of the contents plus the original
    # extension.
    #
    # If a block is given the Magick::ImageList created will be yielded
    # before storage.
    def store_img_data(img_data, &block)
      img = Magick::ImageList.new.from_blob(img_data)
      yield img if block_given?
      store_img(img)
    end

    # Accept a Magick::ImageList and store it locally.
    #
    # The filename will be the md5sum of the contents plus the original
    # extension.
    def store_img(img)
      local_file = self.class.local_file_name(img)
      local_path = File.join(storage_dir, local_file)
      unless File.exists?(local_path)
        Murlsh::openlock(local_path, 'w') { |fout| img.write(fout) }
      end
      local_file
    end

    # Generate the local filename for an image.
    def self.local_file_name(img)
      img.extend(Murlsh::ImageList)
      "#{img.md5}#{img.preferred_extension}"
    end

    attr_reader :storage_dir
  end

end
