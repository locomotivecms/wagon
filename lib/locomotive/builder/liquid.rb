require 'liquid'
require 'locomotive/builder/liquid/drops/base'

%w{. drops tags filters}.each do |dir|
  Dir[File.join(File.dirname(__FILE__), 'liquid', dir, '*.rb')].each { |lib| require lib }
end

# add to_liquid methods to main models from the mounter
%w{site page content_entry}.each do |name|
  # require "locomotive/mounter/models/#{name}"

  klass = "Locomotive::Mounter::Models::#{name.classify}".constantize

  klass.class_eval <<-EOV
    def to_liquid
      ::Locomotive::Builder::Liquid::Drops::#{name.classify}.new(self)
    end
  EOV
end

# ::Liquid::Template.file_system = Locomotive::Builder::Liquid::TemplateFileSystem.new(LocomotiveEditor.site_templates_root)
