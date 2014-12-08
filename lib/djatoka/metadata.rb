# A class for retrieving metadata on a particular image.
# See the Djatoka documentation on the {getMetadata service}[http://sourceforge.net/apps/mediawiki/djatoka/index.php?title=Djatoka_OpenURL_Services#info:lanl-repo.2Fsvc.2FgetMetadata]
class Djatoka::Metadata
  attr_accessor :rft_id, :identifier, :imagefile, :width, :height, :dwt_levels,
    :levels, :layer_count, :response, :resolver
  include Djatoka::Net

  def initialize(resolver, rft_id)
    @resolver = resolver
    @rft_id = rft_id
  end

  # To actually retrieve metadata from the server this method must be called.
  def perform
    @response = get_json(url)
    if @response
      @identifier = response['identifier']
      @imagefile = response['imagefile']
      @width = response['width']
      @height = response['height']
      @dwt_levels = response['dwtLevels']
      @levels = response['levels']
      @layer_count = response['compositingLayerCount']
    end
    self
  end

  # If #perform has been called then this can tell you whether
  # the status of the request was 'OK' or not (nil).
  def status
    if @response
      'OK'
    else
      nil
    end
  end

  # Returns an Addressable::URI which can be used to retrieve metadata from the
  # image server, inspected for query_values, or changed before a request.
  def uri
    uri = Addressable::URI.new(resolver.base_uri_params)
    uri.query_values = {'url_ver'=>'Z39.88-2004','svc_id'=>'info:lanl-repo/svc/getMetadata',
    'rft_id'=>rft_id }
    uri
  end

  # Returns a URL as a String for retrieving metdata from the image server.
  def url
    uri.to_s
  end

  # The Djatoka image server {determines level logic}[http://sourceforge.net/apps/mediawiki/djatoka/index.php?title=Djatoka_Level_Logic]
  # different from the number of dwtLevels. This method determines the height and
  # width of each level. Djatoka only responds with the largest level, so we have
  # to determine these other levels ourself.
  def all_levels
    perform if !response # if we haven't already performed the metadata query do it now
    levels_hash = Hashie::Mash.new
    levels_i = levels.to_i
    (0..levels_i).each do |level_num|
      level_height = height.to_i
      level_width = width.to_i

      times_to_halve = levels_i - level_num
      times_to_halve.times do
        level_height = (level_height / 2.0).round
        level_width = (level_width / 2.0).round
      end

      levels_hash[level_num] = {:height => level_height, :width => level_width}
    end
    levels_hash
  end

  def max_level
    all_levels.keys.sort.last
  end

  # Builds a String containing the JSON response to a IIIF Image Information Request
  #
  # * {Documentation about the Image Info Request}[http://www-sul.stanford.edu/iiif/image-api/#info]
  #
  # It will fill in the required fields of identifier, width, and height.  It will also fill in
  # the scale_factors as determined from Djatoka::Metadata#levels
  # The method yields a Mash where you can set the value of the optional fields.  Here's an example:
  #
  #   metadata.to_iiif_json do |info|
  #     info.tile_width   = 512
  #     info.tile_height  = 512
  #     info.formats      = ['jpg', 'png']
  #     info.qualities    = ['default', 'gray']
  #     info.profile      = 'http://library.stanford.edu/iiif/image-api/compliance.html#level1'
  #     info.image_host   = 'http://myserver.com/image'
  #   end
  def to_iiif_json(&block)
    info = Hashie::Mash.new

    info[:@id]  = @rft_id
    info.width  = @width.to_i
    info.height = @height.to_i

    # optional fields map directly to json from the Mash
    yield(info)

    info[:@context] = info.delete :context

    # convert sizes to integers (if string)
    [info.sizes, info.tiles].each do |prop|
      prop.each do |size|
        size.each { |k, v| size[k] = v.to_i if k =~ /^width|height$/ }
      end
    end

    JSON.pretty_generate(info)
  end

  private
  # Just the levels themselves, as a sorted array of integers
  def levels_as_i
    all_levels.keys.map{ |l| l.to_i}.sort
  end

end
