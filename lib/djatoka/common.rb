# In this module are some methods for some common operations to be done on images.
# These features are more experimental and more likely to break for some images
# at some resolutions.
module Djatoka::Common

  # svc.region - Y,X,H,W.
  # Y is the down inset value (positive) from 0 on the y axis at the max image resolution.
  # X is the right inset value (positive) from 0 on the x axis at the max image resolution.
  # H is the height of the image provided as response.
  # W is the width of the image provided as response.

  # Sets the scale to a 75x75 pixel version of the image and crops any long side
  # to square it. Returns self (a Djatoka::Region.)
  def smallbox
    scale('75')
    square_params
    self
  end

  # An Addressable::URI for a 75x75 version of the image.
  def smallbox_uri
    smallbox
    uri
  end

  # String of #smallbox_uri
  def smallbox_url
    smallbox_uri.to_s
  end

  # public alias for #square_params. Returns self (a Djatoka::Region)
  def square
    square_params(:center)
    self
  end

  def top_left_square
    square_params(:top_left)
    self
  end

  def bottom_right_square
    square_params(:bottom_right)
    self
  end

  # Sets any parameters needed to crop the image to a square and then returns
  # an Addressable::URI.
  def square_uri
    square_params
    uri
  end

  # String of the #square_uri
  def square_url
    square_uri.to_s
  end

  # return a region as a square justified to the top-left of image.
  # for a portrait image it will be justified to the top and for landscape it
  # should be justified to the

  # So far we figure the best level to ask for based on any scale parameter and
  # try to compensate for any difference between the dwtLevels and djatoka levels
  # so that we get a decent image returned.
  def pick_best_level(metadata)
    best_level = metadata.max_level
    metadata_levels = metadata.all_levels
    metadata_levels.keys.sort.reverse.each do |k|
       if metadata_levels[k].height.to_i > query.scale.to_i and
         metadata_levels[k].width.to_i > query.scale.to_i
         best_level = k
       end
    end
    # Here we try to compensate for when the dwtLevels does not match the
    # djatoka levels.
#    if metadata.dwt_levels.to_i > metadata.levels.to_i
#      best_level.to_i - 2
#    elsif metadata.dwt_levels.to_i == metadata.levels.to_i
      best_level.to_i
#    end
  end

  private

  # This is an experimental way to get a decent looking square image at any level.
  # The complication seems to come in where the dwtLevels are different from the
  # how djatoka determines levels. See the comments for the places where the code
  # tries to reconcile this difference in a way that seems to work in the cases
  # seen so far.
  def square_params(justify = :center)
    metadata = Djatoka::Metadata.new(resolver, rft_id).perform
    # since nil.to_i #=> 0 
    # check that height and width are present otherwise our calculations will 
    # fail and raise an error. We want to avoid that and would rather show a 
    # broken image than raise--at least for now. 
    if metadata.height and metadata.width 
      orig_height = metadata.height.to_i
      orig_width = metadata.width.to_i
      if query.scale and query.scale.split.length == 1
        # scaling an image without picking a good level results in poor image
        # quality
        level(pick_best_level(metadata))
      end
      if query.level
        good_query_level = query.level.to_i
        height = metadata.all_levels[good_query_level].height
        width = metadata.all_levels[good_query_level].width
      else
        height = orig_height
        width = orig_width
      end
      # x & y are always the inset of the original image size
      # height and width are relative to the level selected and one if not already
      # a square then the longest side is cropped.
      if height != width
          # portrait
          if height > width
            h = width.to_s
            w = width.to_s
            if justify == :center
              x = '0'
              y = ((orig_height - orig_width)/2).to_s
            elsif justify == :top_left
              x = '0'
              y = '0'
            elsif justify == :bottom_right
              x = '0'
              y = (orig_height - orig_width).to_s
            end

          # landscape
          elsif width > height
            h = height.to_s
            w = height.to_s
            if justify == :center
              y = '0'
              x = ((orig_width - orig_height)/2).to_s
            elsif justify == :top_left
              x = '0'
              y = '0'
            elsif justify == :bottom_right
              y = '0'
              x = (orig_width - orig_height).to_s
            end
          end
        region([y,x,h,w])
      end
    end
  end #square_params

end

