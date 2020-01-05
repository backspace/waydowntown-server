class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  before_action :authenticate_member!
  before_action :set_raven_context

  private def authenticate_member!
    if params[:controller] =~ /^admin\//i
      authenticate_or_request_with_http_basic do |name, token|
        if Member.find_by(name: name, token: token, admin: true)
          true
        else
          head :unauthorized
        end
      end
    else
      member = Member.find_by(token: bearer_token)

      render json: {errors: [{status: "401"}]}, status: :unauthorized unless member
      member
    end
  end

  private def current_member
    @current_member ||= authenticate_member!
  end

  private def current_team
    @current_team ||= current_member.team
  end

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
