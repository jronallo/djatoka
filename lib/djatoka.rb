$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

# In the context of Djatoka a <tt>uri</tt> is an Addressable::URI and a
# <tt>url</tt> is a String representation of that uri.
module Djatoka
  # for use with Rails to allow for configuration
  def self.resolver=(url)
    if url.is_a? Djatoka::Resolver
      @resolver = url
    elsif url.is_a? String
      @resolver = Djatoka::Resolver.new(url)
#      if resolver.valid?
#        @resolver = resolver
#      else
#        @resolver = nil
#      end
    end
  end
  def self.resolver
    @resolver
  end

  # Allows for using curb if available. Otherwise falls back on Net::HTTP. See Djatoka::Net
  def self.use_curb=(curb)
    @use_curb = curb
  end
  def self.use_curb?
    @use_curb
  end
  class << self
    # Calls enable_actionpack
    def enable
      enable_actionpack
    end
    # Requires the Djatoka Rails view helpers
    def enable_actionpack
      return if ActionView::Base.instance_methods.include? :djatoka_image_tag
      require 'djatoka/view_helpers'
      ActionView::Base.send :include, ViewHelpers
    end
  end
end

begin
  require 'curb'
  Djatoka.use_curb = true
rescue LoadError
  Djatoka.use_curb = false
end

require 'net/http'
  require 'uri'

require 'djatoka/net'
require 'djatoka/resolver'
require 'djatoka/metadata'
require 'djatoka/common'
require 'djatoka/region'

require 'rubygems'
require 'addressable/uri'
require 'addressable/template'
require 'json'
require 'mash'


if defined? Rails
  Djatoka.enable_actionpack if defined? ActionController
end

