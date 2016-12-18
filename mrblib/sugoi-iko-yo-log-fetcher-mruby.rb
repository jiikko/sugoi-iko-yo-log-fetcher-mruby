def __main__(argv)
  if argv[1] == "version"
    puts "v#{SugoiIkoYoLogFetcherMruby::VERSION}"
  else
    SugoiIkoYoLogFetcherMruby::Runner.new(argv).download!
  end
end
