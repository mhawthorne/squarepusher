require 'fileutils'
require 'optparse'

FlickRawOptions = {}

$fileutils = FileUtils::Verbose

module Squarepusher
  
  class Client
    
    def initialize(key, secret, token, args={})
      FlickRawOptions['timeout'] = args[:timeout] || 5
      
      require 'flickraw'
      
      FlickRaw.api_key = key
      FlickRaw.shared_secret = secret
      
      flickr.auth.checkToken(:auth_token => token)
      
      # FlickRaw.auth_token = token
      # FlickRaw.timeout = 5
      
      size = args[:size] || :large
      
      @url_for_photo = case size
          when :original
            lambda { |p| FlickRaw.url_o(p) }
          when :large
            lambda { |p| FlickRaw.url_b(p) }
          when :medium_640
            lambda { |p| FlickRaw.url_z(p) }
          when :medium_500
            lambda { |p| FlickRaw.url(p) }
          when :small
            lambda { |p| FlickRaw.url_m(p) }
          when :thumb
            lambda { |p| FlickRaw.url_t(p) }
          when :small_square
            lambda { |p| FlickRaw.url_s(p) }
          else
            raise Exception("unrecognized size: #{size}")
      end
    end
    
    def each_photoset
      flickr.photosets.getList.each do |pset|
        yield pset
      end
    end
    
    def download_photoset(photoset, output_dir)
      set_dir = File.join(output_dir, photoset.title.gsub(/\s+/, '-'))
      $fileutils.mkdir_p set_dir
      
      photos = flickr.photosets.getPhotos(:photoset_id => photoset.id, :extras => "original_format,url_o")["photo"]
      photos.each do |p|
        # puts p.inspect
        name = p.title.gsub(/[^\w_+\.-]/, '-')
        
        url = @url_for_photo[p]
        
        path = File.join(set_dir, "#{name}.jpg")
        if File.exists?(path)
          puts "#{path} exists; skipping"
        else
          download_image(url, path)
        end
      end
    end
 
    private
    
      def download_image(url, path)
        puts "#{url} -> #{path}"
        uri = URI.parse(url)
        Net::HTTP.start(uri.host, uri.port) do |http|
          full_path = uri.request_uri
          response = http.get(full_path)
      
          # puts response.inspect
          case response
            when Net::HTTPError
            when Net::HTTPFound
              location = response["location"]
              if not location =~ /^http.*/
                location = "#{uri.scheme}://#{uri.host}:#{uri.port}#{location}"
              end
              download_image(location, path)
            else
              open(path, 'w') do |out|
                out << response.body
              end
          end
        end
      end
      
  end
  
end