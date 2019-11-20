require 'erb'
require 'locomotive/steam/middlewares/concerns/helpers'
require 'locomotive/steam/middlewares/thread_safe'

module Locomotive::Wagon
  module Middlewares

    # Display a nice page error
    #
    class ErrorPage < Locomotive::Steam::Middlewares::ThreadSafe

      include Locomotive::Steam::Middlewares::Concerns::Helpers

      def _call
        begin
          self.next
        rescue StandardError => error
          @error      = error
          @file_name  = get_error_file_name(error)

          log_error
          render_error_page
        end
      end

      private

      def log_error
        log "Error: #{@error.message}".red
        log @error.backtrace.join("\n")
      end

      def get_error_file_name(error)
        return nil unless error.respond_to?(:template_name)

        site_path = Locomotive::Steam.configuration.adapter[:path]

        case error.template_name
        when /^(snippets|sections)--(.+)$/
          File.join(site_path, "app/views/#{$1}/#{$2}.liquid")
        else
          error.template_name
        end
      end

      def render_error_page
        _template = ERB.new(template, nil, '-')
        render_response(_template.result(binding))
      rescue Exception => e
        puts e.inspect
        'Unknown error'
      end

      def template
        %{
<DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

  <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
    <head>
      <title>Wagon - Rendering error</title>
      <link href="https://fonts.googleapis.com/css?family=Muli:300,400,700" rel="stylesheet" />
      <style>
        body { margin: 0px; padding: 0px; font-family: 'Muli', sans-serif; }
        div { padding: 20px; }
        h1 {
          margin: 0px;
          padding: 20px 0px;
          text-align: center;
          color: #fff;
          background: #E1535E;
        }
        h2 {
          font-size: 40px;
          text-align: center;
        }
        h3 {
          text-transform: uppercase;
          font-weight: normal;
        }
        h3 strong { font-weight: bold; text-transform: none; }
        p {
          font-weight: 300;
          line-height: 22px;
          margin: 20px 20px 30px;
        }
        pre {
          margin: 20px 20px 30px;
          padding: 20px 0px 20px 0px;
          border-left: 4px solid #CACACA;
          background: #FAFAFA;
          box-sizing: border-box;
          line-height: 20px;
        }
        pre strong {
          margin-right: 20px;
        }

        .backtrace-title {
          cursor: pointer;
        }

        .backtrace-title {
          display: block;
        }

        .backtrace.hidden {
          display: none;
        }
      </style>
      <script>
        document.addEventListener('DOMContentLoaded', function() {
          var el = document.querySelector('h3.backtrace-title');
          el.onclick = function() {
            document.querySelector('.backtrace').classList.toggle('hidden');
          }
        });
      </script>
    </head>

    <body>
      <h1>Arrrghhhh, we could not render your page</h1>

      <div>
        <h2><%= @error.message %></h2>

        <% if @file_name %>
          <h3>File</h3>
          <p><%= @file_name %></p>
        <% end %>

        <% if @error.respond_to?(:action) %>
          <h3>Action</h3>
          <p><%= @error.action %></p>
        <% end %>

        <% if @error.respond_to?(:code_lines) %>
          <h3>Code</h3>
          <pre>
  <% @error.code_lines.each do |(line, statement)| -%>
  <strong><%= line %></strong> <%= ERB::Util.html_escape(statement) %>
  <% end -%>
          </pre>
        <% else %>
          <p><i>No code</i></p>
        <% end %>

        <h3 class="backtrace-title">Backtrace <small>(click here to display it)</small></h3>
        <p class="backtrace hidden"><%= @error.backtrace.join("<br/>") %></p>
      </div>

    </body>
  </html>}
      end

    end

  end
end
