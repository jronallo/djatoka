require 'helper'

class TestDjatokaCommon < Test::Unit::TestCase

context 'A Djatoka Resolver' do
    with_a_resolver do
      setup do
        @region = Djatoka::Region.new(@resolver, @identifier)
      end
      should 'create a query for a 75x75 version of the image' do
        assert_equal '0,874,105,105', @region.smallbox.query.region
        assert_equal '75', @region.smallbox.query.scale
      end

      should 'return a String for a smallbox URL' do
        assert @region.smallbox_url.is_a? String
        assert @region.smallbox_url.include? 'http://african.lanl.gov'
        assert @region.smallbox_url.include? 'svc.region=0%2C874%2C105%2C105'
      end

      should 'return a uri for a small square version of the image' do
        assert_equal '0,874,105,105', @region.smallbox.uri.query_values['svc.region']
      end

      should 'create a query for a square version of the image' do
        assert_equal '0,874,3372,3372', @region.square.query.region
        assert_equal nil, @region.square.query.scale
      end
      should 'create a query for a left justified version of the image' do
        assert_equal '0,0,3372,3372', @region.top_left_square.query.region
      end
      should 'create a query for a right justified version of the image' do
        assert_equal '0,1750,3372,3372', @region.bottom_right_square.query.region
      end
      should 'return a uri for a square version of the image' do
        assert_equal '0,874,3372,3372', @region.square_uri.query_values['svc.region']
        assert_equal nil, @region.square_uri.query_values['svc.scale']
      end
      should 'return a url for a square version of the image' do
        assert @region.square_url.is_a? String
        assert @region.square_url.include? 'http://african.lanl.gov'
        assert @region.square_url.include? 'svc.region=0%2C874%2C3372%2C3372'
      end
      should 'create a query for a square version of the image at a good level' do
        @region.scale('555')
        assert_equal '0,874,843,843', @region.square.query.region
        assert_equal '555', @region.square.query.scale
        assert_equal '4', @region.square.query.level
      end

      should 'pick the best level' do
        metadata = Djatoka::Metadata.new(@resolver, @identifier).perform
        @region.scale('200')
        best_level = @region.pick_best_level(metadata)
        assert_equal 2, best_level
      end

      context 'an image which is higher than it is wider' do
        setup do
          @region = Djatoka::Region.new(@resolver, 'info:lanl-repo/ds/b820f537-26a1-4af8-b86a-e7a4cac6187a')
        end
        should 'crop appropriately into a centered square' do
          assert_equal '513,0,4093,4093', @region.square.query.region
        end
        should 'crop appropriately into a top justified square' do
          assert_equal '0,0,4093,4093', @region.top_left_square.query.region
        end
        should 'crop appropriately into bottom justified square' do
          assert_equal '1027,0,4093,4093', @region.bottom_right_square.query.region
        end
      end

      context 'an image where the dwt_levels do not match the djatoka levels' do
        setup do
          @region2 = Djatoka::Region.new(@resolver, 'ua023_015-006-bx0003-014-075')
        end
        should 'be able to scale properly' do
          @region2.scale('300').square
          assert @region2.url
        end
      end



    end

  end
end

