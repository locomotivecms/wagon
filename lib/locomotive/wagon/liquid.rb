require 'liquid'
require 'locomotive/mounter'
require 'locomotive/wagon/liquid/scopeable'
require 'locomotive/wagon/liquid/drops/base'
require 'locomotive/wagon/liquid/tags/hybrid'

%w{. drops tags filters}.each do |dir|
  Dir[File.join(File.dirname(__FILE__), 'liquid', dir, '*.rb')].each { |lib| require lib }
end

# add to_liquid methods to main models from the mounter
%w{site page content_entry}.each do |name|
  klass = "Locomotive::Mounter::Models::#{name.classify}".constantize

  klass.class_eval <<-EOV
    def to_liquid
      ::Locomotive::Wagon::Liquid::Drops::#{name.classify}.new(self)
    end
  EOV
end
