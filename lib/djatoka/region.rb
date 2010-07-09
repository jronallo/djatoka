class Djatoka::Region
  attr_accessor :resolver, :rft_id, :query

  def initialize(resolver, rft_id)
    if resolver.is_a? String
      @resolver = Djatoka::Resolver.new(resolver)
    else
      @resolver = resolver
    end
    @rft_id = rft_id
    @query = Mash.new
  end

  def url(more_query_params={})
    uri(more_query_params={}).to_s
  end

  def uri(more_query_params={})
    uri = Addressable::URI.new(resolver.base_uri_params)
    uri.query_values = region_params.merge(more_query_params)
    uri
  end

  def svc_query
    prefixed_query = {}
    query.each do |k,v|
      prefixed_query['svc.' + k] = v
    end
    prefixed_query
  end

  def scale(v)
    if v.is_a? String or v.is_a? Integer or v.is_a? Float
      query[:scale] = v.to_s
    elsif v.is_a? Array
      raise Djatoka::Region::Exception if v.length != 2
      query[:scale] = v.join(',')
    end
    self
  end

  def level(v)
    if v.is_a? String or v.is_a? Integer
      query[:level] = v.to_s
    end
    self
  end

  def rotate(v)
    if v.is_a? String or v.is_a? Integer
      query[:rotate] = v.to_s
    end
    self
  end

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

  def region_base_url_params
    {'url_ver'=>'Z39.88-2004', 'svc_id'=>'info:lanl-repo/svc/getRegion',
      'svc_val_fmt'=>'info:ofi/fmt:kev:mtx:jpeg2000',
      'rft_id' => rft_id
    }
  end

end

