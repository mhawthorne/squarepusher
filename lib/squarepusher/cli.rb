#!/usr/bin/env ruby

require 'yaml'


module Squarepusher
  
class CLI
  
  class << self
    
    def error_msg(msg)
      $stderr.puts "ERROR - #{msg}"
    end

    def fail(msg, code=1)
      error_msg(msg)
      exit code
    end

    def parse_config(path)
      parsed = nil
      open(path) do |stream|
        parsed = YAML.load(stream)
      end
      if not parsed.respond_to?(:has_key?)
        raise Exception.new("invalid YAML in #{path}; parsed #{parsed.inspect}")
      end
      puts "parsed config: #{parsed.inspect}"
      required_keys = ['key', 'secret', 'token', 'token_secret']
      missing_keys = []
      vals = []
      required_keys.each do |k|
        v = parsed.fetch(k, nil)
        if not v.nil?
          vals << v
        else
          missing_keys << k 
        end
      end
      if not missing_keys.empty?
        raise Exception.new("missing keys in #{path}: #{missing_keys.inspect}")
      end
      vals
    end

    def main
      actions = {}

      actions[:list_sets] = lambda do |client, args|
        client.each_photoset do |pset|
          puts Squarepusher.describe_photoset(pset)
        end
      end

      actions[:grab_all_sets] = lambda do |client, args|
        if args.size != 1
          fail("expected: <output_dir>")
        end
  
        output_dir = args[0]
  
        total_results = {}
        client.each_photoset do |pset|
          pset_description = Squarepusher.describe_photoset(pset)
          puts "[set] #{pset_description}"
          pset_results = client.download_photoset(pset, output_dir)
          puts "[results] #{pset_description} #{pset_results.inspect}"
          total_results[pset_description] = pset_results
          puts
        end
  
        total_results.each_pair do |k, v|
          puts "#{k}: #{v.inspect}"
        end
      end

      actions[:grab_set] = lambda do |client, args|
        if args.size != 2
          fail("expected: <photoset_id> <output_dir>")
        end
  
        pset_id, output_dir = args
        pset = client.get_photoset(pset_id)
        results = client.download_photoset(pset, output_dir)
        puts results.inspect
      end

      actions[:find_set] = lambda do |client, args|
        if args.size != 1
          fail("expected: <photoset_id>")
        end
  
        pset_id, output_dir = args
        pset = client.get_photoset(pset_id)
        puts Squarepusher.describe_photoset(pset)
      end


      def action_str(actions)
        actions.keys.join(",")
      end

      def size_str
        Squarepusher.sizes.join(",")
      end

      options = { :size => :original }
      args = nil
      action = nil
      client = nil
      config_path = "#{ENV['HOME']}/.squarepusher.yaml"
      OptionParser.new do |opts|
        opts.banner = "USAGE: squarepusher [options] <action:(#{action_str(actions)})> [args]"

        opts.on("-c", "--config", "path to config file (defaults to #{config_path})") do |v|
          options[:config] = v
        end

        opts.on("-o", "--overwrite", "overwrite already downloaded files") do |v|
          options[:overwrite] = v
        end

        opts.on("-s", "--size SIZE", "size of photos to download (#{size_str()})") do |v|
          options[:size] = v.to_sym
        end
  
        opts.on("-v", "--verbose", "log verbosely") do |v|
          options[:verbose] = v
        end
  
        opts.parse!(ARGV)
  
        if ARGV.size < 1
          $stderr.puts opts
          exit 1
        end
  
        action = ARGV.delete_at(0)
        args = ARGV
  
        action = action.to_sym
        if not actions.has_key?(action)
          $stderr.puts opts
          exit 2
        end
  
        config_path = options[:config] || config_path
        if not File.exists?(config_path)
          fail "#{config_path} not found" 
        else
          puts "parsing #{config_path}"
        end
        
        key, secret, token, token_secret = parse_config(config_path)
        client = Squarepusher::Client.new(key, secret, token, token_secret, options)
      end
      
      puts "args: #{args.inspect}"
      actions[action].call(client, args || [])
    end
    
  end
  
end

end