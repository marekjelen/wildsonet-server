require "java"

require "wildsonet-netty"
require "rack"

require  File.join(File.dirname(__FILE__), "..", "jars", "wildsonet_server.jar")

require "wildsonet-server-version"

# Wildsonet namespace
module Wildsonet

  # Rack extensions from Wildsonet
  module Server

    java_import "cz.wildsonet.server.RackProxy"
    java_import "cz.wildsonet.server.Server"

    java_import "org.jboss.netty.buffer.ChannelBuffers"
    java_import "org.jboss.netty.handler.codec.http.DefaultHttpResponse"
    java_import "org.jboss.netty.handler.codec.http.HttpResponseStatus"
    java_import "org.jboss.netty.handler.codec.http.HttpVersion"
    java_import "org.jboss.netty.channel.ChannelFutureListener"

    # Rack handler utilizing Netty library. Works with nginx as frontend server to proxy the requests.
    # Netty handles only dynamic requests. Static requests are handled by nginx proxy.

    class Handler

      include RackProxy

      # Starts the server.
      #
      # @param app Rack application to start
      # @param options Options for server
      def self.run app, options = {}
        # Set default options
        options[:Port]      ||= 3000
        options[:Host]      ||= "0.0.0.0"

        # Create new server
        @@server            = Server.new(options[:Host], options[:Port], self.new(app, options))

        Thread.new do
          while true
            Kernel.sleep 10
          end
        end.join

      end

      # Setup the server.
      #
      # @param app Rack application to start
      # @param options Options for server
      def initialize(app, options)
        @app     = ::Rack::Lint.new(app)
        @options = options
      end

      def call env

        ruby = {}

        env.keySet.each do |key|
          case key
            when "rack.input"
              ruby[key] = env[key].to_io
            when "rack.errors"
              ruby[key] = env[key].to_io
            else
              ruby[key] = env[key]
          end
        end

        ruby["rack.version"] = ::Rack::VERSION

        status, headers, body = @app.call(ruby)

        response = DefaultHttpResponse.new(HttpVersion::HTTP_1_1, HttpResponseStatus.valueOf(status))

        headers.each_pair do |header, value|
          response.addHeader(header, value)
        end

        buffer = ChannelBuffers.dynamicBuffer

        body.each do |line|
          buffer.writeBytes(line.to_s.to_java_bytes)
        end

        response.content = buffer

        future = env["wsn.context"].channel.write(response)

        future.addListener(ChannelFutureListener::CLOSE)

        env["rack.input"].close
        File.delete(env["wsn.tempfile"])
        
      end

    end
  end
end

# Register the handler with Rack
Rack::Handler.register "wildsonet", "Wildsonet::Server::Handler"