require 'fileutils'
require 'optparse'

require 'flickraw'

$fileutils = FileUtils::Verbose

module Squarepusher
  
  class Client
    
    def initialize(key, secret, token)
      FlickRaw.api_key = key
      FlickRaw.shared_secret = secret
      
      flickr.auth.checkToken(:auth_token => token)
      
      # FlickRaw.auth_token = token
      # FlickRaw.timeout = 5
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
        name = p.title 
        # short_url = FlickRaw.url_short(p)
        # small_url = FlickRaw.url_s(p)
        # original_url = FlickRaw.url_o(p)
        url = FlickRaw.url_m(p)
        # puts "#{name} #{url}"
        
        path = File.join(set_dir, name)
        if File.exists?(path)
          puts "#{path} exists; skipping"
        else
          download_image(url, path)
        end
      end
    end
 
    private
    
      def download_image(url, path)
        # puts "url: #{url}"
        uri = URI.parse(url)
        # puts url.inspect
        Net::HTTP.start(uri.host, uri.port) do |http|
          full_path = uri.request_uri
          # puts "full_path: #{full_path}"
          response = http.get(full_path)
      
          # puts response.inspect
          case response
            when Net::HTTPError
            when Net::HTTPFound
              location = response["location"]
              # puts "location: #{location}"
              if not location =~ /^http.*/
                location = "#{uri.scheme}://#{uri.host}:#{uri.port}#{location}"
                # puts "transformed location to #{location}"
              end
              download(location, path)
            else
              puts "#{url} -> #{path}"
              # puts "writing #{path}"
              open(path, 'w') do |out|
                out << response.body
                # response.read_body do |part|
                #   out << part
                # end
              end
          end
        end
      end
      
  end
  
end