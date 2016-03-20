#!/usr/bin/env ruby
require 'optparse'
require 'digest/md5'
require 'base64'

def url_sign(resource, path, key, scheme, expires, ip)
  #  1. Setup Token Key
  #  1.1 Prepend leading slash if missing
  path = File.join("/", path) unless path[0] == "/"

  # 1.2 Extract uri, ignore query string arguments
  resource = resource.split("?")[0]

  # 1.3 Formulate the token key
  token = expires + path + key + ip
  
  # 2. Setup URL
  # 2.1 Append argument - secure (compulsory)
  url_secures = "?secure=" + Base64.encode64(Digest::MD5.digest(token)).gsub("+", "-").gsub("/","_").gsub("=","").split("\n")[0]

  # 2.2 Append argument - expires
  url_expires = ""
  url_expires = "&expires=" + expires unless expires.empty?
  
  # 2.3 Append argument - ip
  url_ip = ""
  url_ip = "&ip=" + ip unless ip.empty?

  return scheme + "://" + resource + path + url_secures + url_expires + url_ip

end

# Default value
options = {:resource=>"", :expires=>"", :path=>"", :key=>"", :ip=>"", :scheme=>"http", }
mandatory_item = [:resource, :path, :key]

parser = OptionParser.new do |opts|
    opts.on('-r', '--r resource', 'Resource hostname') do |resource|
        options[:resource] = resource;
    end
  
    opts.on('-p', '--path path', 'Path') do |path|
      options[:path] = path;
    end
    opts.on('-k', '--key key', 'Key') do |key|
      options[:key] = key;
    end
    opts.on('-e', '--expires expires', 'Expires, optional') do |expires|
      options[:expires] = expires;
    end
    opts.on('-i', '--ip ip', 'IP, optional') do |ip|
      options[:ip] = ip;
    end
    opts.on('-s', '--scheme scheme', 'Scheme, http or https, default: http') do |scheme|
      options[:scheme] = scheme;
    end
end

parser.parse!

for item in mandatory_item
  raise OptionParser::MissingArgument, "--#{item} not given" if options[item].empty?
end

if !(options[:scheme] == "http" || options[:scheme] == "https")
  raise OptionParser::ArgumentError, "--scheme http or https"
end

puts url_sign(options[:resource], options[:path], options[:key], options[:scheme], options[:expires], options[:ip])
