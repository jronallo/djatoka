# A class for retrieving metadata on a particular image.
# See the Djatoka documentation on the {getMetadata service}[http://sourceforge.net/apps/mediawiki/djatoka/index.php?title=Djatoka_OpenURL_Services#info:lanl-repo.2Fsvc.2FgetMetadata]
class Djatoka::Metadata
  attr_accessor :rft_id, :identifier, :imagefile, :width, :height, :dwt_levels,
    :levels, :layer_count, :response, :resolver
  include Djatoka::Net

  IIIF_20_CONTEXT_URI         = 'http://iiif.io/api/image/2/context.json'
  IIIF_20_PROTOCOL_URI        = 'http://iiif.io/api/image'
  IIIF_20_BASE_COMPLIANCE_URI = 'http://iiif.io/api/image/2'

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

  # Builds a String containing the JSON-LD response to a IIIF Image Information Request
  #
  # * {Documentation about the Image Info Request}[http://iiif.io/api/image/2.0/#information-request]
  #
  # It will fill in the required @context, @id, protocol, width, height, and profile properties.  It will also fill in
  # sizes as determined from the Djatoka levels from Djatoka::Metadata#levels
  # The method yields a Mash where you can set the value of the optional properties.  Here's an example:
  #
  #   metadata.to_iiif_json do |opts|
  #     opts.tile_width       = 512 # tile_* can be string or int
  #     opts.tile_height      = "512"
  #     opts.compliance_level = 1
  #     opts.formats          = ["jpg", "png"]
  #     opts.qualities        = ["default", "gray"]
  #   end
  def to_iiif_json(iiif_id, &block)
    info = Hashie::Mash.new
    info[:@context] = IIIF_20_CONTEXT_URI
    info[:@id]  = iiif_id
    info.width  = @width.to_i
    info.height = @height.to_i
    info.protocol = IIIF_20_PROTOCOL_URI

    sizes = []
    level_sizes = all_levels
    levels_as_i.each do |l|
      sizes << level_sizes[l]
    end
    info.sizes = sizes

    if block_given?
      opts = Hashie::Mash.new
      yield(opts)
      process_optional_iiif_fields info, opts
    else
      # Assume level 0 compliance if no options passed in
      info.profile = [ "#{IIIF_20_BASE_COMPLIANCE_URI}/level0.json" ]
    end

    JSON.pretty_generate(info)
  end

  private

  def process_optional_iiif_fields info, opts
    tiles = {}
    if opts.tile_width
      tiles["width"] = opts.tile_width.to_i
    end
    if opts.tile_height
      tiles["height"] = opts.tile_height.to_i
    end
    unless tiles.empty?
      tiles["scaleFactors"] = scale_factors

      info.tiles = [tiles]
    end

    profile = []
    if opts.compliance_level
      c_level = opts.compliance_level
    else
      c_level = '0'
    end
    profile << "#{IIIF_20_BASE_COMPLIANCE_URI}/level#{c_level}.json"

    profile_options = {}
    if opts.formats
      profile_options["formats"] = opts.formats
    end
    if opts.qualities
      profile_options["qualities"] = opts.qualities
    end
    profile << profile_options unless profile_options.empty?
    info.profile = profile
  end
  # Just the levels themselves, as a sorted array of integers
  def levels_as_i
    all_levels.keys.map{ |l| l.to_i}.sort.reject{|l| l == 0}
  end

  def scale_factors
    levels_as_i.map do |i|
      2**(i - 1)
    end
  end
end
