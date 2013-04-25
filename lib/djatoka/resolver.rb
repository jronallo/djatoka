# A resolver holds the URL for a Djatoka resolver and allows for
# {ping requests}[http://sourceforge.net/apps/mediawiki/djatoka/index.php?title=Djatoka_OpenURL_Services#info:lanl-repo.2Fsvc.2Fping] to the server and shortcuts for the creation of Djatoka::Region
# and Djatoka::Metadata objects.
class Djatoka::Resolver
  include Djatoka::Net
  attr_accessor :base_url, :scheme, :host, :path, :port

  def initialize(base_url='http://african.lanl.gov/adore-djatoka/resolver')
    #if base_url.to_s =~ /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix
      uri = Addressable::URI.parse(base_url)
      @base_url = uri.to_s
      @scheme = uri.scheme
      @host = uri.host
      @path = uri.path
      @port = uri.port
    #else #fails this basic validation that it is a URL
    #  @base_url = nil
    #  @host = nil
    #  @path = nil
    #end
  end

  # same as #base_url
  def url
    base_url
  end

  # Shortcut to return a Djatoka::Metadata object
  def metadata(rft_id)
    Djatoka::Metadata.new(self, rft_id)
  end

  # Returns a URL as a String for retrieving metadata from the server as JSON.
  def metadata_url(rft_id)
    metadata(rft_id).url
  end

  # Returns a URL as a String which can be used to ping the server.
  def ping_url(rft_id)
    ping_url_template.expand(:rft_id => rft_id).to_str
  end

  # Make a ping request for a particular identifier to the Djatoka server
  # and get a Mash/Hash in return. See the Djatoka docs on
  # {the ping service}[http://sourceforge.net/apps/mediawiki/djatoka/index.php?title=Djatoka_OpenURL_Services#info:lanl-repo.2Fsvc.2Fping]
  def ping(rft_id)
    m_url = ping_url(rft_id)
    response = get_json(m_url)
    if response
      Hashie::Mash.new(response)
    else
      response
    end
  end

  # Shortcut for creating a Djatoka::Region from a Djatoka::Resolver.
  def region(rft_id, params={})
    Djatoka::Region.new(self, rft_id, params)
  end

  # Shortcut for creating an Addressable::URI for a Djatoka::Region.
  def region_uri(rft_id, params={})
    Djatoka::Region.new(self, rft_id, params).uri
  end

  # Shortcut for creating a Djatoka::Region from a Hash of Iiif parameters.
  def iiif_region(rft_id, params={})
    Djatoka::IiifRequest.new(self, rft_id, params).djatoka_region
  end

  # Shortcut for creating an Addressable::URI from a Hash of Iiif parameters.
  def iiif_uri(rft_id, params={})
    Djatoka::IiifRequest.new(self, rft_id, params).djatoka_region.uri
  end

  def base_uri_params
    params = {:host => host, :path => path, :scheme => scheme}
    params[:port] = port if port
    params
  end

  # same as #base_url
  def to_s
    base_url
  end

  private

  def ping_url_template
    Addressable::Template.new("#{base_url}?url_ver=Z39.88-2004&svc_id=info%3Alanl-repo%2Fsvc%2Fping&rft_id={rft_id}")
  end

end

