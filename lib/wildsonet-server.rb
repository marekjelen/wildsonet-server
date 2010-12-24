require "java"

Dir.glob(File.join(File.dirname(__FILE__), "..", "jars", "*")) do |file|
  require file
end

require "wildsonet-server-version"

# WildSoNet namespace
module WildSoNet

  # Rack extensions from WildSoNet
  module Server

    java_import "org.eclipse.jetty.server.Server"
    java_import "org.eclipse.jetty.server.nio.SelectChannelConnector"
    java_import "org.eclipse.jetty.servlet.ServletContextHandler"
    java_import "org.eclipse.jetty.servlet.ServletHolder"

    java_import "org.jruby.embed.PathType"
    java_import "org.jruby.embed.ScriptingContainer"
    java_import "javax.servlet.http.HttpServlet"

    # Rack handler utilizing Jetty web server. Works with nginx as frontend server to proxy the requests.
    # Jetty handles only dynamic requests. Static requests are handled by nginx proxy.

    class Handler < HttpServlet

      # Starts the server.
      #
      # @param app Rack application to start
      # @param options Options for server
      def self.run app, options = {}
        # Set default options
        options[:Port]      ||= 3000
        options[:Host]      ||= "0.0.0.0"

        # Create new server
        @@server            = Server.new

        # Create new connector and configure it according to options
        connector           = SelectChannelConnector.new
        connector.port      = options[:Port]
        connector.host      = options[:Host]

        # Add connector to server
        @@server.connectors = [connector]

        # Create new server context and configure it ad root
        context             = ServletContextHandler.new(ServletContextHandler::NO_SESSIONS)
        context.contextPath = "/"

        # Add context to server
        @@server.handler    = context

        # Create new handler
        servlet             = Handler.new
        servlet.setup(app, options)

        # Connect the handler with context
        context.addServlet(ServletHolder.new(servlet), "/*")

        # Start server
        @@server.start
        @@server.join

      end

      # Stops the server
      def self.shutdown
        # Stop server
        @@server.stop
        @@server = nil
      end

      # Setup the server.
      #
      # @param app Rack application to start
      # @param options Options for server
      def setup(app, options)
        @app     = app
        @options = options

        # By default serve static files from directory "public" in current directory
        @options[:Public] ||= File.expand_path("public") 
      end

      # Handles the request. Servlet method.
      #
      # @param request Request to process
      # @param response Response to the request
      def service request, response
        # "Compute" the path to request file
        file = File.join(@options[:Public], request.getRequestURI())
        # Check file existence
        if File.exists?(file) and File.file?(file)
          # Tell the proxy server(nginx) to serve this request from static files
          response.setHeader("X-Accel-Redirect", "/static" + request.getRequestURI())
        else
          # Process the request
          self.call(request, response)
        end
      end

      # Process the request
      #
      # @param request Request to be processed
      # @param response Response to the request
      def call request, response

        # Prepare basic Rack environment
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
            "rack.errors"       => $stderr,
            "rack.multithread"  => true,
            "rack.multiprocess" => false,
            "rack.run_once"     => false,

            # If this environment parameter is true after request processing, returned body will not be written to response
            "wildsonet.written" => false
        }

        # Process HTTP headers from request; transforms header names into Rack format, if nil returned, the header is skipped
        request.getHeaderNames().each do |name|
          key = self.header_handler(name)
          if key
            env[key] = request.getHeader(name)
          end
        end

        # Process the request
        status, headers, content = @app.call(env)

        # Copy headers from Rack response to Servlet response
        headers.each_pair do |key, value|
          response.addHeader(key, value)
        end

        # Set response status
        response.setStatus(status)

        # Copy the content of request into Servlet output stream(writer)
        # Skips this step if environment parameter was set to true 
        content.each do |part|
          response.writer.write(part)
        end unless env["wildsonet.written"]

      end

      # Processes header names to Rack format
      #
      # @param name Header name to transform
      # @return Rack formatted header name or nil to skip the header
      def header_handler name
        "HTTP_" + name.to_s.sub("-", "_").upcase
      end

    end
  end
end

# Register the handler with Rack
Rack::Handler.register "wildsonet", "WildSoNet::Server::Handler"