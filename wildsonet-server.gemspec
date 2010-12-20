# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{wildsonet-server}
  s.version = "0.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Marek Jelen"]
  s.date = %q{2010-12-20}
  s.description = %q{Server backend for WildSoNet}
  s.email = %q{marek@jelen.biz}
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "jars/jetty-continuation-7.2.0.v20101020.jar",
    "jars/jetty-http-7.2.0.v20101020.jar",
    "jars/jetty-io-7.2.0.v20101020.jar",
    "jars/jetty-security-7.2.0.v20101020.jar",
    "jars/jetty-server-7.2.0.v20101020.jar",
    "jars/jetty-servlet-7.2.0.v20101020.jar",
    "jars/jetty-util-7.2.0.v20101020.jar",
    "jars/servlet-api-2.5.jar",
    "lib/wildsonet-server.rb",
    "test/helper.rb",
    "test/test_wildsonet-server.rb",
    "wildsonet-server.gemspec"
  ]
  s.homepage = %q{http://github.com/marekjelen/wildsonet-server}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Server backend for WildSoNet}
  s.test_files = [
    "test/helper.rb",
    "test/test_wildsonet-server.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 0"])
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.1"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
      s.add_runtime_dependency(%q<rack>, ["> 1.0"])
    else
      s.add_dependency(%q<activesupport>, [">= 0"])
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.1"])
      s.add_dependency(%q<rcov>, [">= 0"])
      s.add_dependency(%q<rack>, ["> 1.0"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 0"])
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.1"])
    s.add_dependency(%q<rcov>, [">= 0"])
    s.add_dependency(%q<rack>, ["> 1.0"])
  end
end

