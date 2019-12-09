require 'rails_helper'

RSpec.describe "Teams", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:member) { Member.create(name: 'me', team: team) }
  let!(:team) { Team.create(name: 'us') }
  let!(:other_team) { Team.create(name: 'them') }

  describe "GET /teams" do
    it "fails without a token" do
      get '/teams'
      expect(response).to have_http_status(401)
    end

    it "fails without a token" do
      get '/teams', headers: { "Authorization" => "Bearer #{member.token}" }
      expect(response).to have_http_status(200)

      expect_record team, type: 'team'
      expect_record other_team, type: 'team'
      expect_item_count 2
    end
  end
end
