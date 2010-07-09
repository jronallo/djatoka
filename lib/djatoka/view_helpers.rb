module Djatoka
  module ViewHelpers
    def djatoka_image_tag(resolver, rft_id, params={})
      region = Djatoka::Region.new(resolver, rft_id)
      image_tag region.url
    end
  end
end

