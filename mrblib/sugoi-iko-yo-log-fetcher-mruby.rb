def __main__(argv)
  if argv[1] == "version"
    puts "v#{SugoiIkoYoLogFetcherMruby::VERSION}"
  else
    SugoiIkoYoLogFetcherMruby::Runner.new(*argv[1..-1]).download!
  end
end
