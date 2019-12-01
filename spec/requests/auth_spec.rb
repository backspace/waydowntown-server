require 'rails_helper'

RSpec.describe "Auth", type: :request do
  describe "POST /auth" do
    let(:member) { Member.create(name: 'me', team: team) }
    let(:team) { Team.create(name: 'us') }

    it "returns the token’s team" do
      post '/auth', headers: { "Authorization" => "Bearer #{member.token}" }
      expect(response).to have_http_status(201)

      expect_record member, type: "member"
      expect_relationship key: "team", type: "team", id: team.id.to_s, included: true
    end

    it "responds with 401 when the token is invalid" do
      post '/auth', headers: { "Authorization" => "Bearer 1312" }
      expect(response).to have_http_status(401)
    end
  end
end
