require 'helper'

class TestDjatoka < Test::Unit::TestCase
  should 'allow Djatoka.use_curb to be set' do
    Djatoka.use_curb=true
    assert Djatoka.use_curb?
    set_testing_curb
  end

  with_a_resolver do
    should 'be able to set Djatoka.resolver to a Djatoka::Resolver' do
      Djatoka.resolver = @resolver
      assert Djatoka.resolver.is_a? Djatoka::Resolver
    end

    should 'be able to set Djatoka.resolver to a URL and get a Djatoka::Resolver' do
      Djatoka.resolver = 'http://african.lanl.gov/adore-djatoka/resolver'
      assert Djatoka.resolver.is_a? Djatoka::Resolver
      assert_equal 'http://african.lanl.gov/adore-djatoka/resolver', Djatoka.resolver.url
    end

    should_eventually 'not be able to set a Djatoka.resolver to a bad string' do
      Djatoka.resolver = 'asdf'
      assert Djatoka.resolver.nil?
    end
  end

end

