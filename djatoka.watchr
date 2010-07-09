watch( 'test/test_.*\.rb' )  {|md| system("rake test") }
watch( 'lib/(.*)\.rb' )      {|md| system("rake test") }

