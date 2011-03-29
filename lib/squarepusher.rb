require 'fileutils'
require 'optparse'

FlickRawOptions = {}

$fileutils = FileUtils::Verbose

# TODO: detect "photo unavailable" and don't download image
UNAVAILABLE_URL = 'http://l.yimg.com/g/images/photo_unavailable.gif'

# TODO: keep track of failures

module Squarepusher
  
  class << self
    
    def describe_photoset(pset)
      "#{pset.id} #{pset.title}"
    end
    
    def normalize(name)
      name.gsub(/[^a-zA-Z0-9_+\.=-]+/, '-')
    end
    
    def sizes
       return [:original, :large, :medium_640, :medium_500, :small, :thumb, :small_square]
    end
  end

  class Client
    
    def initialize(key, secret, token, args={})
      FlickRawOptions['timeout'] = args[:timeout] || 5
      
      require 'flickraw'
      
      FlickRaw.api_key = key
      FlickRaw.shared_secret = secret
      
      flickr.auth.checkToken(:auth_token => token)
      
      # FlickRaw.auth_token = token
      # FlickRaw.timeout = 5
      
      size = args[:size] || :small_square
      
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
    
    def get_photoset(pset_id)
      flickr.photosets.getInfo(:photoset_id => pset_id)
    end
    
    def each_photoset
      flickr.photosets.getList.each do |pset|
        yield pset
      end
    end
    
    def download_photoset(photoset, output_dir)
      dirname = Squarepusher.normalize(photoset.title)
      set_dir = File.join(output_dir, dirname)
      $fileutils.mkdir_p set_dir
      
      # handles socket timeout when loading photoset info
      results = {}
      status, photoset_result = handle_error { flickr.photosets.getPhotos(:photoset_id => photoset.id, :extras => "original_format,url_o")["photo"] }
      if status == :error
        $stderr.puts photoset_result
        results[status] = 1
        return results
      else
        photos = photoset_result
      end
      
      photos.each do |p|
        # puts p.inspect
        
        # TODO: use name of file in url since titles can be duplicate
        name = p.id
        if not p.title.empty?
          normalized_title = Squarepusher.normalize(p.title)
          name << "-#{normalized_title}"
        end
        
        url = @url_for_photo[p]
        
        # TODO: only add .jpg suffix if it's not in the image name already
        path = File.join(set_dir, name)
        path << ".jpg" if not path =~ /.jpg$/
        
        if File.exists?(path)
          puts "#{path} exists; skipping"
          result = :exists
        else
          result = download_image(url, path)
        end
        
        if results.has_key?(result)
          results[result] = results[result] + 1
        else
          results[result] = 1
        end
      end
      results
    end
 
    private
    
      def download_image(url, path, args={})
        if url == UNAVAILABLE_URL
          redirects = args[:redirects]
          msg = "#{url} unavailable"
          msg << "; redirects: #{redirects}" if not redirects.nil?
          puts msg
          return :unvailable
        end
        
        result = :unknown
        # puts url
        uri = URI.parse(url)
        begin
          Net::HTTP.start(uri.host, uri.port) do |http|
            full_path = uri.request_uri
            response = http.get(full_path)
      
            # puts response.inspect
            case response
              when Net::HTTPError
                result = :error
              when Net::HTTPFound
                redirects = args[:redirects] || []
                redirects << url
                location = response["location"]
                if not location =~ /^http.*/
                  location = "#{uri.scheme}://#{uri.host}:#{uri.port}#{location}"
                end
                download_image(location, path, :redirects => redirects)
              else
                puts "#{url} -> #{path}"
                open(path, 'w') do |out|
                  out << response.body
                end
                result = :success
            end
          end
        rescue Error => e
          $stderr.puts e
          result = :error
        end
        return result
      end
      
      def handle_error
        raise Exception("block required") if not block_given?
        begin
          block_result = yield
          result = [:success, block_result]
        rescue Error => e
          result = [:error, e]
        end
        return result
      end
      
  end
  
end