class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  private def bearer_token
    pattern = /^Bearer /
    header  = request.headers['Authorization']
    header.gsub(pattern, '') if header && header.match(pattern)
  end
end
