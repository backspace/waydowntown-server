class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  before_action :set_raven_context

  private def bearer_token
    pattern = /^Bearer /
    header  = request.headers['Authorization']
    header.gsub(pattern, '') if header && header.match(pattern)
  end

  private def set_raven_context
    Raven.user_context(bearer_token: bearer_token)
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end
end
