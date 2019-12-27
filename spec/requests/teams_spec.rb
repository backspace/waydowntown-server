require 'rails_helper'

RSpec.describe "Teams", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:member) { Member.create(name: 'me', team: team) }
  let!(:team) { Team.create(name: 'us') }

  let!(:other_member) { Member.create(team: other_team, lat: 19, lon: 19) }
  let!(:other_team) { Team.create(name: 'them') }

  describe "GET /teams" do
    it "fails without a token" do
      get '/teams'
      expect(response).to have_http_status(401)
    end

    it "responds with a token with limited information" do
      get '/teams', headers: { "Authorization" => "Bearer #{member.token}" }
      expect(response).to have_http_status(200)

      expect_record team, type: 'team'
      expect_record other_team, type: 'team'
      expect_item_count 2

      expect_record other_member, type: "member", included: true
      other_member_record = find_record other_member, type: "member", included: true

      expect(other_member_record[:attributes][:lat]).to be_blank
    end

    context "when the requesting member is an admin" do
      before do
        member.update(admin: true)
      end

      it "responds with a token with more information" do
        get '/teams', headers: { "Authorization" => "Bearer #{member.token}" }
        expect(response).to have_http_status(200)

        other_member_record = find_record other_member, type: "member", included: true

        expect(other_member_record[:attributes][:lat]).to eq("19.0")
      end
    end
  end
end
