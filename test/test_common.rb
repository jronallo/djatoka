require 'helper'

class TestDjatokaCommon < Test::Unit::TestCase

context 'A Djatoka Resolver' do
    setup do
      @resolver = Djatoka::Resolver.new('http://african.lanl.gov/adore-djatoka/resolver')
      @identifier = 'info:lanl-repo/ds/5aa182c2-c092-4596-af6e-e95d2e263de3'
      @url_encoded_identifier = 'info%3Alanl-repo%2Fds%2F5aa182c2-c092-4596-af6e-e95d2e263de3'
    end

    should 'create a uri for a 75x75 version of the image' do
      assert_equal '0,874,3372,3372', @resolver.smallbox_uri(@identifier).query_values['svc.region']
      assert_equal '75', @resolver.smallbox_uri(@identifier).query_values['svc.scale']
    end

    should 'return a String for a smallbox URL' do
      assert @resolver.smallbox_url(@identifier).is_a? String
    end

    should 'return a uri for a square version of the image' do
      assert_equal '0,874,3372,3372', @resolver.square_uri(@identifier).query_values['svc.region']
      assert_equal nil, @resolver.square_uri(@identifier).query_values['svc.scale']
      puts @resolver.square_url(@identifier)
    end

  end
end

