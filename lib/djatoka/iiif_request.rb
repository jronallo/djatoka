require 'mime/types'
require 'set'

# For rotation param testing.  Allows you to do the following with String:
#  '123.456'.numeric? => true
class String
  def numeric?
    return true if self =~ /^\d+$/
    true if Float(self) rescue false
  end
end


# Classes that aid in the translation of International Image Interoperability Framework (IIIF) paramaters into Djatoka requests.
# See {this page}[http://www-sul.stanford.edu/iiif/image-api/#size] for documentation on the IIIF API
#
# Usage example:
#   resolver = Djatoka::Resolver.new('http://server.edu/adore-djatoka/resolver')
#   id = 'someImageId1234'
#
#   request = Djatoka::IiifRequest.new(resolver, id)
#   djatoka_region = request.region('full').size('full').rotation('0').quality('native').format('jpg').djatoka_region

module Djatoka

  class IiifException < Exception; end

  class IiifInvalidParam < IiifException

    def initialize (param_name, value=nil)
      @param_name = param_name
      @value = value
    end

    def to_s
      "#{@param_name.capitalize} is invalid: " << @value.to_s
    end

  end

  # A class for translating IIIF paramaters into a Djatoka::Region object
  # It behaves like the Djatoka::Region object, in that you can chain methods together when setting params.
  # Once you've set all the params, call #djatoka_region to translate the paramaters.  Validation of
  # values occurs in this method, and a Djatoka::IiifInvalidParam exception is raised if any of the values
  # are invalid.
  class IiifRequest

    ALL_PARAMS = Set.new(['region', 'size', 'rotation', 'quality', 'format'])

    attr_accessor :iiif_params

    # You can set the params for the request in 2 ways:
    # 1) pass in params as a hash with the IIIF paramaters {:id => 'some/id', :region => 'full'...}
    # 2) do not pass in params, and use the chain methods to set each value
    def initialize(resolver, id, params = nil)
      @id = id
      @resolver = resolver
      if(!params.nil? && params.is_a?(Hash))
        params.keys.each do |k|
          self.call("k", params[k])
        end
      end
      # else, params is nil, the caller will set each value
      @iiif_params = Hashie::Mash.new
    end

    def id(v)
      @iiif_params[:id] = v
      self
    end

    def region(v)
      @iiif_params[:region] = v
      self
    end

    def size(v)
      @iiif_params[:size] = v
      self
    end

    def rotation(v)
      @iiif_params[:rotation] = v
      self
    end

    def quality(v)
      @iiif_params[:quality] = v
      self
    end

    def format(v)
      @iiif_params[:format] = v
      self
    end

    def all_params_present?
      names = Set.new(@iiif_params.keys)
      names == ALL_PARAMS
    end

    def djatoka_region
      unless(all_params_present?)
        current = Set.new(@iiif_params.keys)
        missing = (ALL_PARAMS - current).to_a
        msg = "Invalid IIIF request.  The following params are missing: " << missing.join(',')
        raise IiifException.new(msg)
      end

      region = @resolver.region(@iiif_params[:id])

      if(@iiif_params[:region] =~ /^(\d+),(\d+),(\d+),(\d+)$/)
        region.region("#{$2},#{$1},#{$4},#{$3}")
      elsif(!(@iiif_params[:region] =~ /^full$/i))
        raise IiifInvalidParam.new "region", @iiif_params[:region]
      end

      s = @iiif_params[:size]
      case s
      when /^full$/i
        s #noop
      when /^(\d+),$/
        region.scale( ["#{$1}", "0"] ) #w => w,0
      when /^,(\d+)$/
        region.scale( ["0", "#{$1}"] ) #h => 0,h
      when /^pct:(\d+)$/i
        dj_scale = $1.to_f / 100.0
        region.scale(dj_scale.to_s)
      when /^(\d+),(\d+)$/
        region.scale("#{$1},#{$2}")
      # TODO Best Fit: when /^!(\d+),(\d+)$/
      else
        raise IiifInvalidParam.new "size", s
      end

      if(@iiif_params[:rotation] && !(@iiif_params[:rotation].numeric?))
        raise IiifInvalidParam.new "rotation", @iiif_params[:rotation]
      end
      region.rotate(@iiif_params[:rotation])

      f = @iiif_params[:format]
      if(f)
        if(f =~ /\//)
          type = MIME::Types[f].first
        else
          type = MIME::Types.type_for(@iiif_params[:format]).first
        end
        raise IiifInvalidParam.new("format", f) if(type.nil?)
      else
        #default to jpg or let djatoka determine default
        type = MIME::Types.type_for('jpg').first
      end
      region.format(type.to_s)

      unless(@iiif_params[:quality] =~ /^(native|color|grey|bitonal)$/i)
        raise IiifInvalidParam.new 'quality', @iiif_params[:quality]
      end

      region

    end

  end

end