
# For rotation param testing.  Allows you to do the following with String:
#  '123.456'.numeric? => true
class String
  def numeric?
    return true if self =~ /^\d+$/
    true if Float(self) rescue false
  end
end

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

  #  A class for translating IIIF parameters into a Djatoka::Region object.
  #
  #  * See the {documentation for the IIIF API}[http://www-sul.stanford.edu/iiif/image-api/#size]
  #
  #  It behaves like the Djatoka::Region object, in that you can chain methods together when setting params.
  #  Once you've set all the params, call #djatoka_region to translate the parameters.  Validation of
  #  values occurs in this method, and a Djatoka::IiifInvalidParam exception is raised if any of the values
  #  are invalid.
  #
  #  *  Usage example
  #   resolver = Djatoka::Resolver.new('http://server.edu/adore-djatoka/resolver')
  #   id = 'someImageId1234'
  #
  #   request = Djatoka::IiifRequest.new(resolver, id)
  #   djatoka_region = request.region('full').size('full').rotation('0').quality('default').format('jpg').djatoka_region
  class IiifRequest

    ALL_PARAMS = Set.new(['region', 'size', 'rotation', 'quality', 'format'])

    attr_accessor :iiif_params

    # You can set the params for the request in 2 ways:
    # 1. Pass in params as a hash with the IIIF parameters {:id => 'some/id', :region => 'full'...}
    # 2. Do not pass in params, and use the chain methods to set each value
    def initialize(resolver, id, params = nil)
      @id = id
      @resolver = resolver
      @iiif_params = Hashie::Mash.new

      if(!params.nil? && params.is_a?(Hash))
        params.keys.each do |k|
          self.send("#{k}", params[k])
        end
      end
      # else, params is nil, the caller will set each value
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

      region = @resolver.region(@id)
      offsets = []
      region_dimensions = []

      case @iiif_params[:region]
      when 'full'
        # noop
      when 'square'
        w = metadata.width.to_i
        h = metadata.height.to_i
        min, max = [w,h].minmax

        offset = (max - min) / 2

        region_dimensions = [min, min]

        if h >= w
          offsets = [0, offset]
        else
          offsets = [offset, 0]
        end
      when /^(\d+),(\d+),(\d+),(\d+)$/
        offsets = [$1, $2]
        region_dimensions = [$3, $4]
      when /^pct:([\d\.]+),([\d\.]+),([\d\.]+),([\d\.]+)$/
        x = (($1.to_f / 100.0) * metadata.width.to_f).to_i
        y = (($2.to_f / 100.0) * metadata.height.to_f).to_i
        w = (($3.to_f / 100.0) * metadata.width.to_f).to_i
        h = (($4.to_f / 100.0) * metadata.height.to_f).to_i
        offsets = [x, y]
        region_dimensions = [w, h]
      else
        raise IiifInvalidParam.new "region", @iiif_params[:region]
      end

      s = @iiif_params[:size]

      case s
      when /^full$/i
        s #noop
      when /^(\d+),$/
        region.scale( ["#{$1}", "0"] ) #w => w,0
        region.level(djatoka_level((region_dimensions.first || metadata.width).to_i / $1.to_f))
      when /^,(\d+)$/
        region.scale( ["0", "#{$1}"] ) #h => 0,h
        region.level(djatoka_level((region_dimensions.last || metadata.height).to_i / $1.to_f))
      when /^pct:(\d*\.?\d*)$/i
        dj_scale = $1.to_f / 100.0
        level = djatoka_level(1 / dj_scale)
        reduce = max_level - level.to_i
        region.scale((dj_scale * 2**reduce).to_s)
        region.level(level)
      when /^(\d+),(\d+)$/
        region.scale("#{$1},#{$2}")
        region.level(djatoka_level((region_dimensions.first || metadata.width).to_i / $1.to_f))
      when /^!(\d+),(\d+)$/
        region_dimensions = [metadata.width.to_f, metadata.height.to_f] if region_dimensions.empty?
        scale = [$1.to_f / region_dimensions.first.to_f, $2.to_f / region_dimensions.last.to_f].min

        width = region_dimensions.first.to_f * scale
        height = region_dimensions.last.to_f * scale

        region.scale([width.ceil, height.ceil])
        region.level(djatoka_level(region_dimensions.first.to_f / width))
      else
        raise IiifInvalidParam.new "size", s
      end

      unless offsets.empty?
        reduce = max_level - region.query.fetch(:level, max_level).to_i
        w, h = region_dimensions.map { |d| d.to_i / (2**reduce) }

        x, y = offsets
        region.region("#{y},#{x},#{h},#{w}")
      end

      unless(@iiif_params[:rotation].numeric?)
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

      unless(@iiif_params[:quality] =~ /^(default|color|gray|bitonal)$/i)
        raise IiifInvalidParam.new 'quality', @iiif_params[:quality]
      end

      region

    end

    def djatoka_level(ratio)
      return max_level if ratio <= 1
      level = max_level - Math.log2(ratio).to_i

      if level < 1
        1
      else
        level
      end
    end

    def max_level
      @max_level ||= metadata.levels.to_i
    end

    def metadata
      @metadata ||= @resolver.metadata(@id).perform
    end
  end

end
