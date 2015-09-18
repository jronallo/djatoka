require 'helper'

class TestDjatokaIiifRequest < Test::Unit::TestCase
  with_a_resolver do
    context 'creates Djatoka::Region objects' do
      setup do
        @req = Djatoka::IiifRequest.new(@resolver, @identifier)
      end

      context 'from a IIIF request with all defaults' do
        setup do
          @region = @req.region('full').size('full').rotation('0').quality('default').format('jpg').djatoka_region
        end

      	should 'set id properly' do
      	  assert_equal @identifier, @region.rft_id
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

      context 'translates region parameters' do
        setup do
          @req.size('full').rotation('0').quality('default').format('jpg')
        end

        should 'set x,y,w,h requests' do
          reg = @req.region('10,20,50,100').djatoka_region
          assert_equal '20,10,100,50', reg.query.region
        end

        should 'set pct:x,y,w,h requests' do
          reg = @req.region('pct:10.5,20,30.8,40').djatoka_region
          assert_equal '674,537,1348,1576', reg.query.region
        end

        should 'raise an exception if the region does not fit the x,y,w,h format, or is not "full"' do
          assert_raise Djatoka::IiifInvalidParam do
            @req.region('blah').djatoka_region
          end
        end
      end

      context 'translates region and size into DWT levels' do
        context 'with a given region' do
          setup do
            @req.region('0,0,800,600').rotation('0').quality('default').format('jpg')
          end

          should 'set levels to the correct scale value' do
            reg = @req.size('1600,').djatoka_region
            assert_equal '6', reg.query.level

            reg = @req.size('800,').djatoka_region
            assert_equal '6', reg.query.level

            reg = @req.size('400,').djatoka_region
            assert_equal '5', reg.query.level

            reg = @req.size('399,').djatoka_region
            assert_equal '5', reg.query.level

            reg = @req.size('200,').djatoka_region
            assert_equal '4', reg.query.level
          end
        end

        context 'with the full image' do
          setup do
            @req.region('full').rotation('0').quality('default').format('jpg')
          end

          should 'set levels to the correct scale value' do
            reg = @req.size('5120,').djatoka_region
            assert_equal '6', reg.query.level

            reg = @req.size('399,').djatoka_region
            assert_equal '3', reg.query.level
          end
        end

        context 'with a pct size' do
          setup do
            @req.region('full').rotation('0').quality('default').format('jpg')
          end

          should 'set levels to the correct scale value' do
            reg = @req.size('pct:100').djatoka_region
            assert_equal '6', reg.query.level

            reg = @req.size('pct:125').djatoka_region
            assert_equal '6', reg.query.level

            reg = @req.size('pct:50').djatoka_region
            assert_equal '5', reg.query.level

            reg = @req.size('pct:49').djatoka_region
            assert_equal '5', reg.query.level

            reg = @req.size('pct:23.52').djatoka_region
            assert_equal '4', reg.query.level
          end
        end
      end

      context 'translates size parameters' do
        setup do
          @req.region('10,20,50,100').rotation('0').quality('default').format('jpg')
        end

        should 'set "w," requests to the correct scale value' do
          reg = @req.size('800,').djatoka_region
          assert_equal '800,0', reg.query.scale
        end

        should 'set ",h" requests to the correct scale value' do
          reg = @req.size(',900').djatoka_region
          assert_equal '0,900', reg.query.scale
          assert_equal '6', reg.query.level
        end

        should 'set "pct:n" requests to the correct scale value' do
          reg = @req.size('pct:75').djatoka_region
          assert_equal '0.75', reg.query.scale
          assert_equal '6', reg.query.level

          reg = @req.size('pct:125').djatoka_region
          assert_equal '1.25', reg.query.scale
          assert_equal '6', reg.query.level

          reg = @req.size('pct:20').djatoka_region
          assert_equal '0.8', reg.query.scale
          assert_equal '4', reg.query.level

          reg = @req.size('pct:6.25').djatoka_region
          assert_equal '1.0', reg.query.scale
          assert_equal '2', reg.query.level
        end

        should 'set "w,h" requests to the correct scale value' do
          reg = @req.size('1024,768').djatoka_region
          assert_equal '1024,768', reg.query.scale
        end

        should 'set "!w,h" requests to the correct scale value' do
          reg = @req.size('!1024,768').djatoka_region
          assert_equal '384,768', reg.query.scale

          reg = @req.size('!1024,500').djatoka_region
          assert_equal '250,500', reg.query.scale
        end

        should 'raise an exception if the value cannot be parsed into a Float' do
          assert_raise Djatoka::IiifInvalidParam do
            @req.size('pct:0.7.5').djatoka_region
          end
        end

      end

      context 'translates rotation parameters' do
        setup do
          @req.region('10,20,50,100').size('800,').quality('default').format('jpg')
        end

        should 'set values that are numeric' do
          reg = @req.rotation('90').djatoka_region
          assert_equal '90', reg.query.rotate

          reg = @req.rotation('270').djatoka_region
          assert_equal '270', reg.query.rotate
        end

        should 'raise an exception if the value is not numeric' do
          assert_raise Djatoka::IiifInvalidParam do
            @req.rotation('blah').djatoka_region
          end
        end
      end

      context 'translates format parameters' do
        setup do
          @req.region('full').size('full').rotation('0').quality('default')
        end

        should 'set the format from a valid extension as from the end of a URL' do
          reg = @req.format('image.png').djatoka_region
          assert_equal 'image/png', reg.query.format
        end

        should 'set the format from a valid mime-type as from the "Accept:" HTTP header' do
          reg = @req.format('image/tiff').djatoka_region
          assert_equal 'image/tiff', reg.query.format
        end

        should 'raise an exception if the value is not a valid mime type extension' do
          assert_raise Djatoka::IiifInvalidParam do
            @req.format('nobody').djatoka_region
          end
        end

        should 'raise an exception if the value is not a valid mime type value' do
          assert_raise Djatoka::IiifInvalidParam do
            @req.format('image/blahtype').djatoka_region
          end
        end
      end

      context 'validates quaility parameters' do
        setup do
          @req.region('full').size('full').rotation('0').format('jpg')
        end

        should 'not raise when the quality is valid' do
          assert_nothing_raised do
            @req.quality('color').djatoka_region
          end
        end

        should 'raise an exception when the quality is invalid' do
          assert_raise Djatoka::IiifInvalidParam do
            @req.quality('3d').djatoka_region
          end
        end
      end

      context '#all_params_present?' do
        should 'return true when all the valid params have been set' do
          @req.region('full').size('full').rotation('0').quality('default').format('jpg')
          assert @req.all_params_present?
        end

        should 'return false when params are missing' do
          @req.region('full').size('full').quality('default').format('jpg')
          assert_equal false, @req.all_params_present?
        end
      end

      context '#djatoka_region' do
        should 'raise a IiifException if a required param is missing from the request' do
          assert_raise Djatoka::IiifException do
            @req.size('800,').djatoka_region
          end
        end
      end
    end #context
  end #with_a_resolver
end
