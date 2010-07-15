require 'helper'

class TestDjatokaResolver < Test::Unit::TestCase
  with_a_resolver do
    context 'A Djatoka Resolver' do

      should 'hold a good host from a base_url' do
        assert_equal 'african.lanl.gov', @resolver.host
      end

      should 'hold a good path from a base_url' do
        assert_equal '/adore-djatoka/resolver', @resolver.path
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

      context 'a ping request using net::http' do
        setup do
          Djatoka.use_curb=false
        end
        should 'return an OK status for a good request' do
          assert_equal 'OK', @resolver.ping(@identifier).status
          Djatoka.use_curb=true
        end
        should 'return a nil for a bad request' do
          ping_response = @resolver.ping('asdf')
          assert_equal nil, ping_response
          Djatoka.use_curb=true
        end
      end

      should 'create a region from a resolver' do
        assert @resolver.region(@identifier).is_a? Djatoka::Region
      end
      should 'create a region uri from a resolver' do
        assert @resolver.region_uri(@identifier).is_a? Addressable::URI
      end

    end #context a Djatoka::Resolver

    context 'a resolver with a port number' do
      setup do
        @resolver_port = Djatoka::Resolver.new('http://example.com:8080/adore-djatoka/resolver')
      end
      should 'hold good uri data' do
        assert_equal 'example.com', @resolver_port.host
        assert_equal 8080, @resolver_port.port
        assert_equal '/adore-djatoka/resolver', @resolver_port.path
      end
      should 'create a good metadata uri' do
        metadata_url = Djatoka::Metadata.new(@resolver_port, 'asdf').uri
        assert_equal 8080, metadata_url.port
      end
      should 'create a metadata url' do
        metadata_url = @resolver_port.metadata_url(@identifier)
        assert metadata_url.is_a? String
        assert metadata_url.include?('getMetadata')
      end
      should 'create a good url' do
        assert_equal 'http://example.com:8080/adore-djatoka/resolver', @resolver_port.url
      end
    end #context: resolver with a port number

  end #with_a_resolver
end

