require 'erb'
require 'locomotive/steam/middlewares/thread_safe'
require 'locomotive/steam/middlewares/helpers'

module Locomotive::Wagon
  module Middlewares

    # Display a nice page error
    #
    class ErrorPage < Locomotive::Steam::Middlewares::ThreadSafe

      include Locomotive::Steam::Middlewares::Helpers

      def _call
        begin
          self.next
        rescue StandardError => error
          @error = error
          log_error
          render_error_page
        end
      end

      private

      def log_error
        log "Error: #{@error.message}".red
        log @error.backtrace.join("\n")
      end

      def render_error_page
        _template = ERB.new(template, nil, '-')
        render_response(_template.result(binding))
      end

      def template
        %{
<DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

  <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
    <head>
      <title>Wagon - Rendering error</title>
    </head>

    <body>
      <h1>Arrrghhhh, we could not render page</h1>
      <h2><%= @error.message %></h2>

      <h3>File: <%= @error.respond_to?(:file) ? @error.file : '?' %></h3>

      <h3>Code</h3>
      <% if @error.respond_to?(:code_lines) %>
        <pre>
<% @error.code_lines.each do |(line, statement)| -%>
<strong><%= line %></strong> <%= statement %>
<% end -%>
        </pre>
      <% else %>
        <p><i>No code</i></p>
      <% end %>

      <h3>Back trace</h3>
      <%= @error.backtrace.join("<br/>") %>

    </body>
  </html>}
      end

    end

  end
end
