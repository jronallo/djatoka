class Djatoka::Metadata
  attr_accessor :rft_id, :identifier, :imagefile, :width, :height, :dwt_levels,
    :levels, :layer_count, :response, :resolver
  include Djatoka::Curb

  def initialize(resolver, rft_id)
    @resolver = resolver
    @rft_id = rft_id

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
  end

  def status
    if @response
      'OK'
    else
      nil
    end
  end

  def url
    metadata_url_template.expand(:rft_id => rft_id).to_str
  end

  private

   def metadata_url_template
    Addressable::Template.new("#{resolver.base_url}?url_ver=Z39.88-2004&svc_id=info:lanl-repo/svc/getMetadata&rft_id={rft_id}")
  end

end

