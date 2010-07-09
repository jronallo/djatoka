require 'rubygems'
require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'djatoka'

class Test::Unit::TestCase
  def self.with_a_resolver(&block)
    context 'resolver setup' do
      setup do
        @resolver = Djatoka::Resolver.new('http://african.lanl.gov/adore-djatoka/resolver')
        @identifier = 'info:lanl-repo/ds/5aa182c2-c092-4596-af6e-e95d2e263de3'
        @url_encoded_identifier = 'info%3Alanl-repo%2Fds%2F5aa182c2-c092-4596-af6e-e95d2e263de3'
      end

      merge_block(&block) if block_given?
    end
  end

end

