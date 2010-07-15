require 'helper'

class TestDjatokaViewHelpers < Test::Unit::TestCase
  with_a_resolver do
    context 'Rails view helpers' do
      should 'be true' do
        assert true
      end
      should_eventually 'Test the Rails view helpers' do
        assert_equal '', djatoka_image_tag(@identifier)
      end
    end
  end
end

