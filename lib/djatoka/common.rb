class Djatoka::Region

  # svc.region - Y,X,H,W.
  # Y is the down inset value (positive) from 0 on the y axis at the max image resolution.
  # X is the right inset value (positive) from 0 on the x axis at the max image resolution.
  # H is the height of the image provided as response.
  # W is the width of the image provided as response.

  def smallbox
    scale('75')
    square_params
    self
  end

  def smallbox_uri(params={})
    smallbox
    uri(params)
  end

  def smallbox_url(params={})
    smallbox_uri(params).to_s
  end

  def square_uri(params={})
    square_params
    uri(params)
  end

  def square_url(params={})
    square_uri(params).to_s
  end

  private

  def square_params
    metadata = Djatoka::Metadata.new(resolver, rft_id)
    if metadata
      height = metadata.height.to_i
      width = metadata.width.to_i
      if height != width
        if height > width
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
        region([y,x,h,w])
      end
    end
  end

end

