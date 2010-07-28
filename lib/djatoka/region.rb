# Class to ease the creation of query parameters for retrieval of a region of
# an image from the Djatoka image server.
# See the Djatoka documentation on specifics on the {getRegion service}[http://sourceforge.net/apps/mediawiki/djatoka/index.php?title=Djatoka_OpenURL_Services#info:lanl-repo.2Fsvc.2FgetRegion]
#
# Many of the methods here can be chained together to set query parameters like so:
#  region = Djatoka::Region.new('http://african.lanl.gov/adore-djatoka/resolver',
#   'info:lanl-repo/ds/5aa182c2-c092-4596-af6e-e95d2e263de3')
#
#  region.scale(300).format('image/png').region([1250,550,800,800]).rotate(180).level(5).url
#    # => "http://african.lanl.gov/adore-djatoka/resolver?svc.level=5&url_ver=Z39.88-2004&svc.region=1250%2C550%2C800%2C800&svc.scale=300&rft_id=info%3Alanl-repo%2Fds%2F5aa182c2-c092-4596-af6e-e95d2e263de3&svc_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajpeg2000&svc_id=info%3Alanl-repo%2Fsvc%2FgetRegion&svc.format=image%2Fpng&svc.rotate=180"
#
# All of these values are added in to the query attribute of the Djatoka::Region.
# Any of the values which are separated by a comma in the {docs}[http://sourceforge.net/apps/mediawiki/djatoka/index.php?title=Djatoka_OpenURL_Services#info:lanl-repo.2Fsvc.2FgetRegion]
# can be sent in as a String or an Array.
class Djatoka::Region
  include Djatoka::Common
  attr_accessor :resolver, :rft_id, :query

  # Pass in a Djatoka::Resolver (or an http URL as a String) and
  # an rft_id to create a Region. Valid parameters include any of the methods below
  # which add their value to <tt>query</tt> and return self (so they can be
  # chained together).
  def initialize(resolver, rft_id, params={})
    if resolver.is_a? String
      @resolver = Djatoka::Resolver.new(resolver)
    else
      @resolver = resolver
    end
    @rft_id = rft_id
    @query = Hashie::Mash.new
    unless params.empty?
      map_params(params)
    end
  end

  # url for a Region as a String
  def url
    uri.to_s
  end

  # Addressable::URI for the Region
  def uri
    uri = Addressable::URI.new(resolver.base_uri_params)
    uri.query_values = region_params
    uri
  end

  # Take the query values and prefixes 'svc.' for the OpenURL.
  def svc_query
    prefixed_query = {}
    query.each do |k,v|
      prefixed_query['svc.' + k] = v
    end
    prefixed_query
  end

  # Set the scale query parameter as a String or Array. Returns self.
  def scale(v)
    if v.is_a? String or v.is_a? Integer or v.is_a? Float
      query[:scale] = v.to_s
    elsif v.is_a? Array
      raise Djatoka::Region::Exception if v.length != 2
      query[:scale] = v.join(',')
    end
    self
  end

  # Set the level query parameter as a String or Integer. Returns self.
  def level(v)
    if v.is_a? String or v.is_a? Integer
      query[:level] = v.to_s
    end
    self
  end

  # Sets the rotate query parameter as a String or Integer. Returns self.
  def rotate(v)
    if v.is_a? String or v.is_a? Integer
      query[:rotate] = v.to_s
    end
    self
  end

  # Sets the region query parameter as a String or Array. Returns self.
  # See the {Djatoka documentation}[http://sourceforge.net/apps/mediawiki/djatoka/index.php?title=Djatoka_OpenURL_Services#info:lanl-repo.2Fsvc.2FgetRegion]
  # on the valid values for the region parameter and what they mean.
  def region(v)
    if v.is_a? String
      svc_region = v.split(',')
      raise Djatoka::Region::Exception if svc_region.length != 4
      query[:region] = v
    elsif v.is_a? Array
      raise Djatoka::Region::Exception if v.length != 4
      query[:region] = v.join(',')
    end
    self
  end

  # Set the format query parameter for what image format will be returned. Returns self.
  def format(v)
    query[:format] = v
    self
  end

  def clayer(v)
    query[:clayer] = v
    self
  end

  def region_params
    region_base_url_params.merge(svc_query)
  end

  # base parameters for creating a getRegion service OpenURL.
  def region_base_url_params
    {'url_ver'=>'Z39.88-2004', 'svc_id'=>'info:lanl-repo/svc/getRegion',
      'svc_val_fmt'=>'info:ofi/fmt:kev:mtx:jpeg2000',
      'rft_id' => rft_id
    }
  end

  private

  def map_params(params)
    params.each do |k,v|
      if k.to_s != 'resolver' and self.respond_to?(k) and
        self.class.instance_methods(false).include?(k.to_s)
        self.send(k,v)
      end
    end
  end

end

