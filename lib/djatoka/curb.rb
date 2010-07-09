module Djatoka::Curb
  def get_json(url)
    c = Curl::Easy.new(url)
    data = nil
    c.on_success{|curl| data = JSON.parse(curl.body_str) }
    c.perform
    data
  end
end

