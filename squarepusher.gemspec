# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "squarepusher/version"

Gem::Specification.new do |s|
  s.name    = 'squarepusher'
  s.version     = Squarepusher::VERSION
  s.platform    = Gem::Platform::RUBY

  s.authors   = 'mhawthorne'
  s.email    = 'mhawthorne@gmail.com'
  s.homepage = 'https://github.com/mhawthorne/squarepusher'
  s.summary     = "downloads photos from flickr"

  s.add_dependency 'flickraw'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.rubyforge_project = 'nowarning'
end