require 'helper'

class TestDjatokaMetadata < Test::Unit::TestCase
  with_a_resolver do
  context 'a metadata response' do
      setup do
        @metadata = @resolver.metadata(@identifier)
      end

      should 'create a metadata object' do
        assert @metadata.is_a? Djatoka::Metadata
      end

      should "create a metadata URL for an identifier" do
        #'http://african.lanl.gov/adore-djatoka/resolver?url_ver=Z39.88-2004&svc_id=info:lanl-repo/svc/getMetadata&rft_id=info:lanl-repo/ds/5aa182c2-c092-4596-af6e-e95d2e263de3',
        assert_equal 'http://african.lanl.gov/adore-djatoka/resolver?url_ver=Z39.88-2004&svc_id=info:lanl-repo/svc/getMetadata&rft_id=info%3Alanl-repo%2Fds%2F5aa182c2-c092-4596-af6e-e95d2e263de3',
          @metadata.url
      end

      should "return imagefile metadata for an identifier" do
        assert_equal '/lanl/data/loc/cc5fc4f7-e50a-455f-b3ce-a6a8b54824e6/WEJLNXSBWO7LPLC7Z6DITFX7A45XR3GS.jp2',
          @metadata.imagefile
      end

      should 'return an identifier for a good request' do
        assert_equal @identifier,
          @metadata.identifier
      end

      should 'return a height for a good request' do
        assert_equal '3372', @metadata.height
      end

      should 'return a width for a good request' do
        assert_equal '5120', @metadata.width
      end

      should 'return a nil for a bad request' do
        metadata = @resolver.metadata('asdf')
        assert_equal nil, metadata.status
      end
    end
  end

end

