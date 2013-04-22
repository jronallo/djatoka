require 'helper'

class TestDjatokaIiifRequest < Test::Unit::TestCase
  with_a_resolver do
    context 'creates Djatoka::Region objects' do
      setup do
        @req = Djatoka::IiifRequest.new(@resolver, @identifier)
      end

      context 'from a IIIF request with all defaults' do
        setup do
          @region = @req.region('full').size('full').rotation('0').quality('native').format('jpg').djatoka_region
        end

        should 'set region to nil from full' do
          assert_nil @region.query.region
        end

        should 'set size to nil from full' do
          assert_nil @region.query.scale
        end

        should 'set rotation to 0' do
          assert_equal '0', @region.query.rotate
        end

        should 'set format to image/jpg' do
          assert_equal 'image/jpeg', @region.query.format
        end

      end

      context 'translates region paramaters' do
        setup do
          @reg = @req.region('10,20,50,100').size('').rotation('0').quality('native').format('jpg').djatoka_region
        end

        should 'set x,y,w,h requests' do
          assert_equal '20,10,100,50', @reg.query.region
        end
      end

    end #context

  end #with_a_resolver

end

