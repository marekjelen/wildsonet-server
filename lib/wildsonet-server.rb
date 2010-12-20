require "logger"
require "java"

require "active_support/core_ext/class/attribute_accessors.rb"

Dir.glob(File.join(File.dirname(__FILE__), "..", "jars", "*")) do |file|
  require file
end

module WildSoNet
  module Rack

    java_import "org.eclipse.jetty.server.Server"
    java_import "org.eclipse.jetty.server.nio.SelectChannelConnector"
    java_import "org.eclipse.jetty.servlet.ServletContextHandler"
    java_import "org.eclipse.jetty.servlet.ServletHolder"

    java_import "org.jruby.embed.PathType"
    java_import "org.jruby.embed.ScriptingContainer"
    java_import "javax.servlet.http.HttpServlet"

    class Handler < HttpServlet

      cattr_accessor :tester

      def self.run app, options = {}
        @@server            = Server.new
        connector           = SelectChannelConnector.new
        connector.port      = 3000
        @@server.connectors = [connector]
        context             = ServletContextHandler.new(ServletContextHandler::NO_SESSIONS)
        context.contextPath = "/"
        @@server.handler    = context
        servlet             = Handler.new
        servlet.setup(app)
        context.addServlet(ServletHolder.new(servlet), "/*")
        @@server.start
        @@server.join
      end

      def self.shutdown
        @@server.stop
        @@server = nil
      end

      def setup(app)
        @app    = app
        @logger = Logger.new(File.join("log", "rack.log"))
        @errors = File.new(File.join("log", "rack.errors.log"), "a")
      end

      def service request, response
        pub = java.io.File.new("public" + request.getRequestURI())
        if (pub.exists() and pub.isFile())
          response.setHeader("X-Accel-Redirect", "/static" + request.getRequestURI())
        else
          self.call request, response
        end
      end

      def call request, response

        env = {
            "REQUEST_METHOD"    => request.getMethod(),
            "SCRIPT_NAME"       => "",
            "PATH_INFO"         => request.getPathInfo() =~ /^\// ? request.getPathInfo() : "/" + request.getPathInfo(),
            "QUERY_STRING"      => request.getQueryString(),
            "SERVER_NAME"       => request.getServerName(),
            "SERVER_PORT"       => request.getServerPort(),

            "rack.version"      => [1, 1],
            "rack.url_scheme"   => request.isSecure() ? "https" : "http",
            "rack.input"        => request.getInputStream().to_io,
            "rack.errors"       => @errors,
            "rack.multithread"  => true,
            "rack.multiprocess" => false,
            "rack.run_once"     => false,
            #"rack.session"      => Session.new(request.session(true)),
            "rack.logger"       => @logger

        }

        request.getHeaderNames().each do |name|
          key = self.header_handler(name)
          if key
            value    = request.getHeader(name)
            env[key] = value
          end
        end

        status, headers, content = @app.call(env)

        headers.each_pair do |key, value|
          response.addHeader(key, value)
        end

        response.setStatus(status)

        content.each do |part|
          response.writer.write(part)
        end

      end

      def header_handler name
        "HTTP_" + name.to_s.sub("-", "_").upcase
      end

    end
  end
end

Rack::Handler.register "wildsonet", "WildSoNet::Rack::Handler"