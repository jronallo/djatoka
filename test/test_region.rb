require 'helper'

class TestDjatokaMetadata < Test::Unit::TestCase
  with_a_resolver do
    context 'creates image URLs for a region' do
      setup do
        @region = Djatoka::Region.new(@resolver, @identifier)
      end

      should 'create good region parameters' do
        good_params = {'rft_id'=>"info:lanl-repo/ds/5aa182c2-c092-4596-af6e-e95d2e263de3",
                        "svc_val_fmt"=>"info:ofi/fmt:kev:mtx:jpeg2000",
                        "svc_id"=>"info:lanl-repo/svc/getRegion",
                        'url_ver'=>"Z39.88-2004"}
        assert_equal good_params, @region.region_params
      end

      context 'create a new region if given a string as a resolver' do
        should 'create a resolver object' do
          region = Djatoka::Region.new('http://african.lanl.gov/adore-djatoka/resolver', @identifier)
          assert region.resolver.is_a? Djatoka::Resolver
          assert_equal 'http://african.lanl.gov/adore-djatoka/resolver', region.resolver.to_s
          assert_equal 'african.lanl.gov', region.resolver.host
        end
      end

      context 'create a default region uri' do
        setup do
          @region_uri = @region.uri
          @query_values = @region.uri.query_values
        end
        should 'create a default region uri' do
          assert_equal @identifier, @query_values['rft_id']
          assert_equal nil, @query_values['svc.scale']
        end
        should 'output a region url' do
          assert @region.url.is_a? String
          assert @region.url.include? 'http://african.lanl.gov'
        end
      end

      context 'add query parameters' do
        should 'accept a scale as a String' do
          scale_region = @region.scale('96')
          assert_equal '96', scale_region.query.scale
        end
        should 'accept a scale as a single Integer' do
          assert_equal '96', @region.scale(96).query.scale
        end
        should 'accept a scale as a Float' do
          assert_equal '0.5', @region.scale(0.5).query.scale
        end
        should 'accept a scale as an Array of 2' do
          assert_equal '1024,768', @region.scale([1024,768]).query.scale
          assert_equal '10,60', @region.scale(['10', '60']).query.scale
        end

        should 'accept a level as a String' do
          level_region = @region.level('2')
          assert_equal '2', level_region.query.level
        end
        should 'accept a level as an Integer' do
          assert_equal '3', @region.level(3).query.level
        end

        should 'accept a rotate as a String' do
          assert_equal '180', @region.rotate('180').query.rotate
        end
        should 'accept a rotate as an Integer' do
          assert_equal '180', @region.rotate(180).query.rotate
        end

        should 'accept a region as a String' do
          assert_equal '0,0,256,256', @region.region('0,0,256,256').query.region
        end
        should 'accept a region as an Array of Strings' do
          assert_equal '0,0,256,256', @region.region(['0','0','256','256']).query.region
        end
        should 'accept a region as an Array of Integers and/or Floats' do
          assert_equal '0.1,0.1,5,5', @region.region([0.1, 0.1, 5, 5]).query.region
        end

        should 'accept a format as a String' do
          assert_equal 'image/png', @region.format('image/png').query.format
        end
        should 'accept a clayer as a String' do
          assert_equal '0', @region.clayer('0').query.clayer
        end
      end

      context 'add empty or null query parameters' do
        should 'have no value in the uri' do
          assert_equal nil, @region.level(nil).uri.query_values['svc.level']
        end
      end

      context 'create a query uri with svc values' do
        should 'have a svc.scale paramter' do
          assert_equal '96', @region.scale('96').uri.query_values['svc.scale']
        end
        context 'and method chaining' do
          setup do
            @region2 = @region.dup.scale('96').level('3')
            @region2_query_values = @region2.uri.query_values
          end
          should 'have svc.scale and svc.level parameters after method chaining' do
            assert_equal '96', @region2_query_values['svc.scale']
            assert_equal '3', @region2_query_values['svc.level']
          end
          should 'have default values after method chaining svc values' do
            assert_equal 'info:lanl-repo/svc/getRegion', @region2_query_values['svc_id']
          end
        end
      end #context create a query uri with svc values

      context 'create a new region and pass in query parameters' do
        should 'accept param keys as symbols' do
          params = {:level=> 3, :rotate=>180, :region => '0,0,500,500',
            :scale => 75, :format => 'image/png'
          }
          region = Djatoka::Region.new(@resolver,@identifier,params)
          assert_equal '3', region.query.level
          assert_equal '180', region.query.rotate
          assert_equal '0,0,500,500', region.query.region
          assert_equal '75', region.query.scale
          assert_equal 'image/png', region.query.format
        end
        should 'accept param keys as strings' do
          params = {'level'=> 3, 'rotate'=> 180, 'region' => '0,0,500,500',
            'scale' => 75, 'format' => 'image/png'
          }
          region = Djatoka::Region.new(@resolver,@identifier,params)
          assert_equal '3', region.query.level
          assert_equal '180', region.query.rotate
          assert_equal '0,0,500,500', region.query.region
          assert_equal '75', region.query.scale
          assert_equal 'image/png', region.query.format
        end
        should 'not choke on params it responds to but are not instance methods' do
          region = Djatoka::Region.new(@resolver,@identifier,{:class => 'djatoka_image'})
          assert region.is_a? Djatoka::Region
          assert_equal nil, region.uri.query_values['svc.class']
        end
      end

      context 'protocol relative urls' do
        should 'return a protocol relative url' do
          region = Djatoka::Region.new(@resolver, @identifier, {protocol_relative: true})
          assert_equal nil, region.uri.scheme
          assert !region.url.include?('http:')
          assert !region.url.include?('https:')
        end
      end

    end #context

  end #with_a_resolver

end

