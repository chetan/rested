# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rested}
  s.version = "0.4.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Chetan Sarva"]
  s.date = %q{2011-12-19}
  s.description = %q{Ruby library built on top of httpclient for working with RESTful APIs.}
  s.email = %q{chetan@betteradvertising.com}
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    ".gitignore",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "lib/rested.rb",
     "lib/rested/base.rb",
     "lib/rested/debug.rb",
     "lib/rested/entity.rb",
     "lib/rested/error.rb",
     "lib/rested/ext.rb",
     "lib/rested/validations.rb",
     "rested.gemspec"
  ]
  s.homepage = %q{}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Ruby library for working with RESTful APIs}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<httpclient>, [">= 2.1.5.2"])
      s.add_runtime_dependency(%q<json>, [">= 1.4.2"])
    else
      s.add_dependency(%q<httpclient>, [">= 2.1.5.2"])
      s.add_dependency(%q<json>, [">= 1.4.2"])
    end
  else
    s.add_dependency(%q<httpclient>, [">= 2.1.5.2"])
    s.add_dependency(%q<json>, [">= 1.4.2"])
  end
end
