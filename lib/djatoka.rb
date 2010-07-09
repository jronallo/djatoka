$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module Djatoka
  class << self
    def enable
      enable_actionpack
    end
    def enable_actionpack
      return if ActionView::Base.instance_methods.include_method? :djatoka_image_tag
      require 'djatoka/view_helpers'
      ActionView::Base.send :include, ViewHelpers
    end
  end
end

require 'djatoka/curb'
require 'djatoka/resolver'
require 'djatoka/metadata'
require 'djatoka/region'
require 'djatoka/common'

require 'rubygems'
require "addressable/uri"
require "addressable/template"
require 'curb'
require 'json'
require 'mash'


if defined? Rails
  #Djatoka.enable_activerecord if defined? ActiveRecord
  Djatoka.enable_actionpack if defined? ActionController
end

