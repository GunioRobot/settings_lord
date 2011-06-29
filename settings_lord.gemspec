# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require './lib/settings_lord/version.rb'

Gem::Specification.new do |s|
	s.name 				= "settings_lord"
	s.version 		= SettingsLord::Version::STRING
	s.platform 		= Gem::Platform::RUBY
	s.authors			= ["pechrorin andrey"]
	s.email				=	["pechorin.andrey@gmail.com"]
	s.homepage		= "https://github.com/pechorin/settings_lord"
	s.summary			=	%q{Best way to manage your site settings}
	s.description	=	%q{Best way to manage your site settings}

	s.files				= `git ls-files`.split("\n")
	s.test_files  = `git ls-files -- test/*`.split("\n")
	s.require_paths = ["lib"]
end
