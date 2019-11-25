require 'rails_helper'

RSpec.describe "Auth", type: :request do
  describe "POST /auth" do
    let(:team) { Team.create(name: 'us') }

    it "returns the token’s team" do
      post '/auth', headers: { "Authorization" => "Bearer #{team.token}" }
      expect(response).to have_http_status(200)

      expect_record team, type: "team"
    end

    it "responds with 401 when the token is invalid" do
      post '/auth', headers: { "Authorization" => "Bearer 1312" }
      expect(response).to have_http_status(401)
    end
  end
end
