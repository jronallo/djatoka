class Djatoka::Resolver
  include Djatoka::Curb
  attr_accessor :base_url, :host, :path

  def initialize(base_url='http://african.lanl.gov/adore-djatoka/resolver')
    @base_url = base_url
    uri = Addressable::URI.parse(base_url)
    @host = uri.host
    @path = uri.path
  end

  def metadata(rft_id)
    Djatoka::Metadata.new(self, rft_id)
  end

  def ping_url(rft_id)
    ping_url_template.expand(:rft_id => rft_id).to_str
  end

  def ping(rft_id)
    m_url = ping_url(rft_id)
    get_json(m_url)
  end

  def region(rft_id)
    Djatoka::Region.new(self, rft_id)
  end

  def region_uri(rft_id, params={})
    Djatoka::Region.new(self, rft_id).uri(params)
  end

  def base_uri_params
    {:host => host, :path => path, :scheme => 'http'}
  end

  def to_s
    base_url
  end

  private

  def ping_url_template
    Addressable::Template.new("#{base_url}?url_ver=Z39.88-2004&svc_id=info:lanl-repo/svc/ping&rft_id={rft_id}")
  end

end

