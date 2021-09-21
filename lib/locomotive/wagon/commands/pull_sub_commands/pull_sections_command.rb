module Locomotive::Wagon

  class PullSectionsCommand < PullBaseCommand

    def _pull
      api_client.sections.all.each do |section|
        write_section(section)
      end
    end

    def write_section(section)
      write_to_file(section_filepath(section), <<-FRONT_MATTER
#{section.definition.to_yaml}
---
#{section.template}
      FRONT_MATTER
      )
    end

    private

    def section_filepath(section)
      File.join('app', 'views', 'sections', section.slug + '.liquid')
    end

  end

end
