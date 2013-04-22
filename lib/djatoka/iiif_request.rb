require 'mime/types'

# For rotation param testing
class String
  def numeric?
    return true if self =~ /^\d+$/
    true if Float(self) rescue false
  end
end


class Djatoka::IiifRequest
  #attr_accessor :id, :region, :size, :rotation, :quality, :format
  attr_accessor :iiif_params
  # Pass in the IIIF relevant part of the path ({id}/{region}/{size}/{rotation}/{quality}{.format})
  # or pass in a hash with the IIIF paramaters {:id => 'some/id', :region => 'full'...}
  def initialize(resolver, id, params = nil)
    @id = id
    @resolver = resolver
    if(!params.nil? && params.is_a?(Hash))
      params.keys.each do |k|
        self.call("k", params[k])
      end
    end
    @iiif_params = Hashie::Mash.new
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

  def djatoka_region
    region = @resolver.region(@iiif_params[:id])

    if(@iiif_params[:region] =~ /^(\d+),(\d+),(\d+),(\d+)$/)
      region.region("#{$2},#{$1},#{$4},#{$3}")
    elsif(!(@iiif_params[:region] =~ /^full$/i))
      raise Djatoka::IiifRequest::Exception "region is invalid: #{@iiif_params[:region]}"
    end

    s = @iiif_params[:size]
    case s
    when /^full$/i
      s #noop
    when /^(\d+),$/
      region.scale("#{$1},0") #w => w,0
    when /^,(\d+)$/
      region.scale("0,#{$1}") #h => 0,h
    when /^pct:(\d+)$/i
      dj_scale = $1.to_f / 100.0
      region.scale(dj_scale.to_s)
    when /^(\d+),(\d+)$/
      region.scale("#{$1},#{$2}")
    # TODO Best Fit: when /^!(\d+),(\d+)$/
    else
      #raise Djatoka::IiifRequest::Exception "size is invalid: #{s}"
    end

    if(@iiif_params[:rotation] && !(@iiif_params[:rotation].numeric?))
      #raise Djatoka::IiifRequest::Exception "rotation is invalid: #{@iiif_params[:rotation]}"
    end
    region.rotate(@iiif_params[:rotation])

    if(@iiif_params[:format])
      type = MIME::Types.type_for(@iiif_params[:format]).first
    else
      #default to jpg or let djatoka determine default
      type = MIME::Types.type_for('img.jpg').first
    end
    region.format(type.to_s)

    # TODO add check of quality

  end

end