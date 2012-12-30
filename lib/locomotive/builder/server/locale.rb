module Locomotive::Builder
  class Server

    # Set the locale from the path if possible or use the default one
    # Examples:
    #   /fr/index   => locale = :fr
    #   /fr/        => locale = :fr
    #   /index      => locale = :en (default one)
    #
    class Locale < Middleware

      def call(env)
        self.set_accessors(env)

        self.set_locale!(env)

        app.call(env)
      end

      protected

      def set_locale!(env)
        path    = env['builder.path']
        locale  = self.mounting_point.default_locale

        if path =~ /^(#{self.mounting_point.locales.join('|')})+(\/|$)/
          locale  = $1
          path    = path.gsub($1 + $2, '')

          # TODO: I18n.locale ???

          Locomotive::Mounter.locale = locale
        end

        puts "[Builder|Locale] path = #{path.inspect}, locale = #{locale.inspect}"

        env['builder.locale'] = locale
        env['builder.path']   = path
      end

    end
  end
end