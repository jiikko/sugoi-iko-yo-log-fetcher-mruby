MRuby::Gem::Specification.new('sugoi-iko-yo-log-fetcher-mruby') do |spec|
  spec.license = 'MIT'
  spec.author  = 'MRuby Developer'
  spec.summary = 'sugoi-iko-yo-log-fetcher-mruby'
  spec.bins    = ['sugoi-iko-yo-log-fetcher-mruby']

  spec.add_dependency 'mruby-print', :core => 'mruby-print'
  spec.add_dependency 'mruby-mtest', :mgem => 'mruby-mtest'
end
