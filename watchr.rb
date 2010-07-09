#watch( 'test/test_.*\.rb' )  {|md| system("rake test") }
#watch( 'lib/(.*)\.rb' )      {|md| system("rake test") }


def notify(message)
  notify_send = `which notify-send`.chomp
  title = "Watchr Test Results"
  image = message.include?('0 failures, 0 errors') ? '~/.autotest_images/pass.png' : '~/.autotest_images/fail.png'
  msg = message.slice(/(\d+)\stests,\s(\d+)\sassertions,\s(\d+)\sfailures,\s(\d+)\serrors/)
  system %Q{#{notify_send} '#{title}' '#{msg}' -i #{image} -t 2000 &}
end

def run(cmd)
  puts(cmd)
  `#{cmd}`
end


def run_test_file(file)
  system('clear')
  puts file
  result = run(%Q(ruby -I"lib:test" -rubygems #{file}))
  notify result.split("\n").last rescue nil
  puts result
end

def related_test_files(path)
  Dir['test/*.rb'].select { |file| file =~ /test_#{File.basename(path).split(".").first}.rb/ }
end



def run_all_tests
  system('clear')
  result = `rake test`
  notify result.split("\n").last rescue nil
  puts result
end

def run_validation_tests
  system('clear')
  result = `rake test:units TEST=test/test_validations.rb`
  notify result.split("\n").last rescue nil
  puts result
end


watch('test/helper\.rb') { run_all_tests }
watch('test/test_.*\.rb') { run_all_tests }
watch('lib/.*/.*\.rb') { run_all_tests }



# Ctrl-C
Signal.trap 'INT' do
  if @interrupted then
    @wants_to_quit = true
    abort("\n")
  else
    puts "Interrupt a second time to quit"
    @interrupted = true
    Kernel.sleep 1.5
    # raise Interrupt, nil # let the run loop catch it
    run_all_tests
  end
end

