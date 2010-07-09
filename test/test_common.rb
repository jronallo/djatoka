require 'helper'

class TestDjatokaCommon < Test::Unit::TestCase

context 'A Djatoka Resolver' do
    with_a_resolver do
      setup do
        @region = Djatoka::Region.new(@resolver, @identifier)
      end
      should 'create a query for a 75x75 version of the image' do
        assert_equal '0,874,3372,3372', @region.smallbox.query.region
        assert_equal '75', @region.smallbox.query.scale
      end

      should 'return a String for a smallbox URL' do
        assert @region.smallbox_url.is_a? String
      end

      should 'return a uri for a square version of the image' do
        assert_equal '0,874,3372,3372', @region.smallbox.uri.query_values['svc.region']
      end
    end

  end
end

