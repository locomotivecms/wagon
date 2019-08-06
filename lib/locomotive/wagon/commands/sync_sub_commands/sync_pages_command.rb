require 'neatjson'

module Locomotive::Wagon

  class SyncPagesCommand < PullPagesCommand

    include Locomotive::Wagon::BaseConcern

    def write_page(page, locale = nil)
      instrument :writing, label: "#{page.fullpath} (#{locale})"

      filepath = data_path(page, locale)

      return if page.fullpath =~ /^layouts(\/.*)?$/

      attributes = {
        id:                         page._id,
        title:                      page.title,
        slug:                       page.slug,
        handle:                     page.handle,
        listed:                     page.listed,
        published:                  page.published,
        position:                   page.position,
        fullpath:                   @fullpaths[page._id]
      }

      if page.redirect_url.present?
        attributes.merge!({ redirect_url: page.redirect_url })
      else
        attributes.merge!({
          sections_content:           sections_content(page),
          sections_dropzone_content:  sections_dropzone_content(page),
          editable_elements:          editable_elements_attributes(page),
          seo_title:                  page.seo_title,
          meta_description:           page.meta_description,
          meta_keywords:              page.meta_keywords
        })

        attributes[:raw_template] = page.template if page.handle.blank?
      end

      write_to_file(filepath, replace_asset_urls(JSON.neat_generate(attributes)))

      instrument :write_with_success
    end

    private

    def sections_content(page)
      return {} if page.sections_content.blank?
      JSON.parse(page.sections_content)
    end

    def sections_dropzone_content(page)
      return [] if page.sections_dropzone_content.blank?
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

    def data_path(page, locale)
      filepath = @fullpaths[page._id]
      filepath = 'index' if filepath.blank? || filepath == '/' || filepath == "/#{default_locale}"
      File.join('data', env.to_s, 'pages', locale, filepath + '.json')
    end

  end

end
