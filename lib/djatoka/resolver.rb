class Djatoka::Resolver
  attr_accessor :base_url, :host, :path

  def initialize(base_url='http://african.lanl.gov/adore-djatoka/resolver')
    @base_url = base_url
    uri = Addressable::URI.parse(base_url)
    @host = uri.host
    @path = uri.path
  end

  def metadata_url(rft_id)
    metadata_url_template.expand(:rft_id => rft_id).to_str
  end

  def get_metadata(rft_id)
    m_url = metadata_url(rft_id)
    get_json(m_url)
  end

  def ping_url(rft_id)
    ping_url_template.expand(:rft_id => rft_id).to_str
  end

  def ping(rft_id)
    m_url = ping_url(rft_id)
    get_json(m_url)
  end

  def region_url(rft_id, query_params={})
    region_uri(rft_id, query_params={}).to_s
  end

  def region_uri(rft_id, query_params={})
    uri = Addressable::URI.new(base_uri_params)
    full_params = query_params.merge(:rft_id => rft_id)
    uri_params = region_params(full_params)
    uri.query_values = uri_params
    uri
  end

  def region_params(params)
    region_base_url_params.merge(params)
  end

  private

  def base_uri_params
    {:host => host, :path => path, :scheme => 'http'}
  end

  def region_base_url_params
    {:url_ver=>'Z39.88-2004', 'svc_id'=>'info:lanl-repo/svc/getRegion',
      'svc_val_fmt'=>'info:ofi/fmt:kev:mtx:jpeg2000'
    }
  end

  def metadata_url_template
    Addressable::Template.new("#{base_url}?url_ver=Z39.88-2004&svc_id=info:lanl-repo/svc/getMetadata&rft_id={rft_id}")
  end

  def ping_url_template
    Addressable::Template.new("#{base_url}?url_ver=Z39.88-2004&svc_id=info:lanl-repo/svc/ping&rft_id={rft_id}")
  end

  def get_json(url)
    c = Curl::Easy.new(url)
    data = nil
    c.on_success{|curl| data = JSON.parse(curl.body_str) }
    c.perform
    data
  end

end

