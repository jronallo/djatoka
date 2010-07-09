require 'helper'

class TestDjatoka < Test::Unit::TestCase
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

end


  end
end

