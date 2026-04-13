# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'

    with_options headers: :any, credentials: false do
      with_options methods: [:get] do
        resource '/.well-known/*'
        resource '/nodeinfo/*'
        resource '/@:username'
        resource '/users/:username'
      end
      resource '/api/*',
               expose: %w(Link X-RateLimit-Reset X-RateLimit-Limit X-RateLimit-Remaining X-Request-Id),
               methods: %i(post put delete get patch options)
      resource '/oauth/token', methods: [:post]
      resource '/oauth/revoke', methods: [:post]
      resource '/oauth/userinfo', methods: [:get, :post]
    end
  end

  # FEDIWAY: dev-only CORS exception so a frontend on localhost can POST to the
  # credentials endpoint and have the session cookie stick. credentials: true
  # requires a specific origin (not '*'). Off in production unless explicitly set.
  if ENV['FEDIWAY_DEV_CORS_ORIGINS'].present?
    allow do
      origins(*ENV.fetch('FEDIWAY_DEV_CORS_ORIGINS').split(',').map(&:strip))
      resource '/api/fediway/v1/credentials',
               methods: %i(post options),
               headers: :any,
               credentials: true
    end
  end
end
