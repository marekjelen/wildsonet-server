lib = File.join(File.dirname(__FILE__), "lib")
$: << lib unless $:.include?(lib)

require "wildsonet-server-version"

Gem::Specification.new do |s|

  s.name = "wildsonet-server"
  s.version = WildSoNet::Server::VERSION
  s.authors = ["Marek Jelen"]
  s.summary = "Server backends for WildSoNet"
  s.description = "Server backends for WildSoNet"
  s.email = "marek@jelen.biz"
  s.homepage = "http://github.com/marekjelen/wildsonet-server"
  s.licenses = ["MIT"]

  s.platform = "java"
  s.required_rubygems_version = ">= 1.3.6"

  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]

  s.files = [
    "Gemfile",
    "LICENSE.txt",
    "README.rdoc",
    "jars/jetty-continuation-7.2.0.v20101020.jar",
    "jars/jetty-http-7.2.0.v20101020.jar",
    "jars/jetty-io-7.2.0.v20101020.jar",
    "jars/jetty-security-7.2.0.v20101020.jar",
    "jars/jetty-server-7.2.0.v20101020.jar",
    "jars/jetty-servlet-7.2.0.v20101020.jar",
    "jars/jetty-util-7.2.0.v20101020.jar",
    "jars/servlet-api-2.5.jar",
    "lib/wildsonet-server.rb",
    "lib/wildsonet-server-version.rb",
    "wildsonet-server.gemspec"
  ]

  s.require_paths = ["lib"]

  s.test_files = [
  ]

  s.add_runtime_dependency("rack", ["> 1.0"])

end

