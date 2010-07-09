require 'helper'

class TestDjatoka < Test::Unit::TestCase
  context 'A Djatoka Resolver' do
    setup do
      @resolver = Djatoka::Resolver.new('http://african.lanl.gov/adore-djatoka/resolver')
      @identifier = 'info:lanl-repo/ds/5aa182c2-c092-4596-af6e-e95d2e263de3'
      @url_encoded_identifier = 'info%3Alanl-repo%2Fds%2F5aa182c2-c092-4596-af6e-e95d2e263de3'
    end

    should 'hold a good host from a base_url' do
      assert_equal 'african.lanl.gov', @resolver.host
    end

    should 'hold a good path from a base_url' do
      assert_equal '/adore-djatoka/resolver', @resolver.path
    end

    should "create a metadata URL for an identifier" do
      #'http://african.lanl.gov/adore-djatoka/resolver?url_ver=Z39.88-2004&svc_id=info:lanl-repo/svc/getMetadata&rft_id=info:lanl-repo/ds/5aa182c2-c092-4596-af6e-e95d2e263de3',
      assert_equal 'http://african.lanl.gov/adore-djatoka/resolver?url_ver=Z39.88-2004&svc_id=info:lanl-repo/svc/getMetadata&rft_id=info%3Alanl-repo%2Fds%2F5aa182c2-c092-4596-af6e-e95d2e263de3',
        @resolver.metadata_url(@identifier)
    end

    context 'a metadata response' do
      setup do
        @metadata_response = @resolver.get_metadata(@identifier)
      end

      should "return imagefile metadata for an identifier" do
        assert_equal '/lanl/data/loc/cc5fc4f7-e50a-455f-b3ce-a6a8b54824e6/WEJLNXSBWO7LPLC7Z6DITFX7A45XR3GS.jp2',
          @metadata_response['imagefile']
      end

      should 'return an identifier for a good request' do
        assert_equal @identifier,
          @metadata_response['identifier']
      end

      should 'return a height for a good request' do
        assert_equal '3372', @metadata_response['height']
      end


      should 'return a width for a good request' do
        assert_equal '5120', @metadata_response['width']
      end

      should 'return a nil for a bad request' do
        metadata_response = @resolver.get_metadata('asdf')
        assert_equal nil, metadata_response
      end
    end

    should 'create a ping url' do
      assert_equal 'http://african.lanl.gov/adore-djatoka/resolver?url_ver=Z39.88-2004&svc_id=info:lanl-repo/svc/ping&rft_id=info%3Alanl-repo%2Fds%2F5aa182c2-c092-4596-af6e-e95d2e263de3',
        @resolver.ping_url(@identifier)
    end

    context 'a ping request' do
      setup do
        @ping_response = @resolver.ping(@identifier)
      end

      should 'return an OK status for a good request' do
        assert_equal 'OK', @ping_response['status']
      end

      should 'return the identifier for a good request' do
        assert_equal @identifier, @ping_response['identifier']
      end

      should 'return a nil for a bad request' do
        ping_response = @resolver.ping('asdf')
        assert_equal nil, ping_response
      end
    end

    context 'creates image URLs for a region' do
      should 'create good region paramters' do
        good_params = {:rtf_id=>"info:lanl-repo/ds/5aa182c2-c092-4596-af6e-e95d2e263de3",
                        "svc_val_fmt"=>"info:ofi/fmt:kev:mtx:jpeg2000",
                        "svc_id"=>"info:lanl-repo/svc/getRegion", :url_ver=>"Z39.88-2004",
                        }
        assert_equal good_params, @resolver.region_params(:rtf_id => @identifier)
      end

      context 'create a default region uri' do
        setup do
          @region_uri = @resolver.region_uri(@identifier)
          @query_values = @region_uri.query_values
        end
        should 'create a default region uri' do
          assert_equal @identifier, @query_values['rft_id']
          assert_equal nil, @query_values['scale']
        end
      end



    end


  end
end

