Dir[File.join(File.dirname(__FILE__), "/../../../../locales/*.yml")].each do |locale|
  puts "[Builder|I18n] register #{locale}"
  ::I18n.config.load_path << locale
end