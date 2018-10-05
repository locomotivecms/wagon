require 'neatjson'

module Locomotive::Wagon

  class SyncPagesCommand < PullPagesCommand

    include Locomotive::Wagon::BaseConcern

    # def _sync
    #   @fullpaths_by_locale = {}

    #   # first step: we've to build a look-up table to get the fullpath
    #   # of a page from its id.
    #   @pages_by_locale = locales.map do |locale|
    #     pages = []

    #     api_client.pages.all(locale).each do |page|
    #       @fullpaths_by_locale[locale][page._id] = page.fullpath
    #       pages << page
    #     end

    #     [locale, pages]
    #   end

    #   @pages_by_locale.each do |(locale, pages)|
    #     write_page(page, locale)
    #   end

    #   # raise 'TODO'

    #   # @fullpaths = @pages, {}

    #   # locales.each do |locale|
    #   #   api_client.pages.all(locale).each do |page|
    #   #     fullpaths[page._id] = page.fullpath if locale == default_locale
    #   #     write_page(page, locale)
    #   #   end
    #   # end
    # end

    def write_page(page, locale = nil)
      filepath = data_path(page, locale)

      return if page.fullpath =~ /^layouts(\/.*)?$/

      puts "....doing #{filepath} #{page.fullpath} (#{locale}) / #{page.handle} / #{page.is_layout}"

      attributes = {
        id:                         page._id,
        title:                      page.title,
        slug:                       page.slug,
        handle:                     page_handle(page),
        sections_content:           sections_content(page),
        sections_dropzone_content:  sections_dropzone_content(page),
        editable_elements:          editable_elements_attributes(page),
        seo_title:                  page.seo_title,
        meta_description:           page.meta_description,
        meta_keywords:              page.meta_keywords
      }

      write_to_file(filepath, replace_asset_urls(JSON.neat_generate(attributes)))

      # # make sure the target folder exists
      # FileUtils.mkdir_p(File.dirname(filepath))

      # # fill the file with the data of the page in JSON
      # File.open(filepath, 'w') do |f|
      #   f << JSON.neat_generate(attributes)
      # end


      # if is_default_locale?(locale)
      #   filepath = page_filepath(page, locale)

      # else

      # end

      # filepath = page_filepath(page, locale)

      # if File.exists?(filepath)
      #   #
      # end

      # puts [locale, page.title].join(' - ')




      # filepath = page_filepath(page, locale)

      # if File.exists?(filepath)
      #   # only copy the content of the editable elements
      #   if attributes = editable_elements_attributes(page, locale)
      #     new_content = replace_editable_elements(filepath, dump(attributes))

      #     write_to_file(filepath, new_content)
      #   end
      # else
      #   # pull the whole page
      #   super
      # end
    end

    private

    def sections_content(page)
      JSON.parse(page.sections_content)
    end

    def sections_dropzone_content(page)
      JSON.parse(page.sections_dropzone_content)
    end

    def editable_elements_attributes(page)
      page.editable_elements.inject({}) do |hash, el|
        hash["#{el['block']}/#{el['slug']}"] = el['content'] if el['content']
        hash
      end
    end

    def page_handle(page)
      page.handle || (%w(index 404).include?(page.fullpath) ? page.fullpath : nil)
    end

    # def replace_editable_elements(filepath, replacement)
    #   content   = File.read(File.join(path, filepath), encoding: 'utf-8')
    #   existing  = content =~ /\A.*?editable_elements:.*?\n---/m

    #   content.gsub /\A---(.*?)\n---/m do |s|
    #     if existing
    #       s.gsub(/editable_elements:\n(.*?)\n(\S)/m) { |_s| "#{replacement}#{$2}" }
    #     else
    #       s.gsub(/---\Z/) { |_s| "#{replacement}\n---" }
    #     end
    #   end
    # end

    # def page_filepath(page, locale)
    #   fullpath = locale == default_locale ? page.fullpath : "#{fullpaths[page._id]}.#{locale}"

    #   # HAML template?
    #   if File.exists?(filepath = _page_filepath(fullpath, '.haml'))
    #     return filepath
    #   end

    #   # simple Liquid template OR the page does not exist in the local site
    #   _page_filepath(fullpath)
    # end

    # def _page_filepath(fullpath, additional_extension = '')
    #   File.join('app', 'views', 'pages', fullpath + ".liquid#{additional_extension}")
    # end

    def data_path(page, locale)
      filepath = page.localized_fullpaths[default_locale]
      filepath = 'index' if filepath == '/'
      File.join('data', env.to_s, 'pages', locale == default_locale ? '' : locale, filepath + '.json')
    end

  end

end
