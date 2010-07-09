class Djatoka::Resolver

  # svc.region - Y,X,H,W.
  # Y is the down inset value (positive) from 0 on the y axis at the max image resolution.
  # X is the right inset value (positive) from 0 on the x axis at the max image resolution.
  # H is the height of the image provided as response.
  # W is the width of the image provided as response.

  def smallbox_uri(rft_id, params={})
    params['svc.scale'] =  '75'
    params.merge!(square_params(rft_id))
    region_uri(rft_id, params)
  end

  def smallbox_url(rft_id, params={})
    smallbox_uri(rft_id, params).to_s
  end

  def square_uri(rft_id, params={})
    params.merge!(square_params(rft_id))
    region_uri(rft_id, params)
  end

  def square_url(rft_id, params={})
    square_uri(rft_id, params).to_s
  end

  private

  def square_params(rft_id)
    metadata = get_metadata(rft_id)
    if metadata
      height = metadata['height'].to_i
      width = metadata['width'].to_i
      params = {}
      if height != width
        if height > width
          #
          x = '0'
          y = ((height - width)/2).to_s
          h = width.to_s
          w = width.to_s
        elsif width > height
          y = '0'
          x = ((width - height)/2).to_s
          h = height.to_s
          w = height.to_s
        end
        params['svc.region'] = [y,x,h,w].join(',')
      end
      params
    end
  end

end

