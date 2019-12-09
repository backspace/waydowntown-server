require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Waydowntown
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # FIXME adjust before release
    config.middleware.insert_before 0, Rack::Cors, :debug => !Rails.env.production?, :logger => (-> { Rails.logger }) do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get, :post, :patch, :delete, :options]
      end
    end
  end
end

Raven.configure do |config|
  config.dsn = 'https://29f8bdeccb01470b875d4a34cded55b8:01df7d7d1e59440eaaa3ba3a4caed7c7@sentry.io/1848898'
  config.environments = %w[ production ]
end
