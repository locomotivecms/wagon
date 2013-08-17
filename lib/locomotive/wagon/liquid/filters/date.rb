module Locomotive
  module Wagon
    module Liquid
      module Filters
        module Date

          def parse_date_time(input, format = nil)
            return '' if input.blank?

            format    ||= I18n.t('time.formats.default')
            date_time = ::DateTime._strptime(input, format)

            if date_time
              ::Time.zone.local(date_time[:year], date_time[:mon], date_time[:mday], date_time[:hour], date_time[:min], date_time[:sec] || 0)
            else
              ::Time.zone.parse(input) rescue ''
            end
          end

          def parse_date(input, format)
            return '' if input.blank?

            format  ||= I18n.t('date.formats.default')
            date    = ::Date._strptime(input, format)

            if date
              ::Date.new(date[:year], date[:mon], date[:mday])
            else
              ::Date.parse(value) rescue ''
            end
          end

          def localized_date(input, *args)
            return '' if input.blank?

            format, locale = args

            locale ||= I18n.locale
            format ||= I18n.t('date.formats.default', locale: locale)

            if input.is_a?(String)
              begin
                fragments = ::Date._strptime(input, format)
                input = ::Date.new(fragments[:year], fragments[:mon], fragments[:mday])
              rescue
                input = Time.parse(input)
              end
            end

            return input.to_s unless input.respond_to?(:strftime)

            I18n.l input, format: format, locale: locale
          end

          alias :format_date :localized_date

          def distance_of_time_in_words(input, *args)
            return '' if input.blank?

            from_time = input
            to_time   = args[0] || Time.zone.now

            from_time = from_time.to_time if from_time.respond_to?(:to_time)
            to_time = to_time.to_time if to_time.respond_to?(:to_time)
            distance_in_minutes = (((to_time - from_time).abs)/60).round
            distance_in_seconds = ((to_time - from_time).abs).round

            ::I18n.with_options({ scope: :'datetime.distance_in_words' }) do |locale|

              case distance_in_minutes
                when 0..1
                  return distance_in_minutes == 0 ?
                         locale.t(:less_than_x_minutes, count: 1) :
                         locale.t(:x_minutes, count: distance_in_minutes) unless include_seconds

                  case distance_in_seconds
                    when 0..4   then locale.t :less_than_x_seconds, count: 5
                    when 5..9   then locale.t :less_than_x_seconds, count: 10
                    when 10..19 then locale.t :less_than_x_seconds, count: 20
                    when 20..39 then locale.t :half_a_minute
                    when 40..59 then locale.t :less_than_x_minutes, count: 1
                    else             locale.t :x_minutes,           count: 1
                  end

                when 2..44           then locale.t :x_minutes,      count: distance_in_minutes
                when 45..89          then locale.t :about_x_hours,  count: 1
                when 90..1439        then locale.t :about_x_hours,  count: (distance_in_minutes.to_f / 60.0).round
                when 1440..2519      then locale.t :x_days,         count: 1
                when 2520..43199     then locale.t :x_days,         count: (distance_in_minutes.to_f / 1440.0).round
                when 43200..86399    then locale.t :about_x_months, count: 1
                when 86400..525599   then locale.t :x_months,       count: (distance_in_minutes.to_f / 43200.0).round
                else
                  fyear = from_time.year
                  fyear += 1 if from_time.month >= 3
                  tyear = to_time.year
                  tyear -= 1 if to_time.month < 3
                  leap_years = (fyear > tyear) ? 0 : (fyear..tyear).count{|x| ::Date.leap?(x)}
                  minute_offset_for_leap_year = leap_years * 1440
                  # Discount the leap year days when calculating year distance.
                  # e.g. if there are 20 leap year days between 2 dates having the same day
                  # and month then the based on 365 days calculation
                  # the distance in years will come out to over 80 years when in written
                  # english it would read better as about 80 years.
                  minutes_with_offset         = distance_in_minutes - minute_offset_for_leap_year
                  remainder                   = (minutes_with_offset % 525600)
                  distance_in_years           = (minutes_with_offset / 525600)
                  if remainder < 131400
                    locale.t(:about_x_years,  count: distance_in_years)
                  elsif remainder < 394200
                    locale.t(:over_x_years,   count: distance_in_years)
                  else
                    locale.t(:almost_x_years, count: distance_in_years + 1)
                  end
              end
            end
          end

        end

        ::Liquid::Template.register_filter(Date)
      end
    end
  end
end