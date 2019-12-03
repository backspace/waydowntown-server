require 'rails_helper'

RSpec.describe "Games", type: :request do

  let(:member) { Member.create(name: 'me', team: team) }
  let(:team) { Team.create(name: 'us') }
  let(:other_team) { Team.create(name: 'them') }

  let!(:game) { Game.create(incarnation: incarnation, teams: [team, other_team]) }
  let(:incarnation) { Incarnation.create }

  let(:team_channel_spy) { class_spy('TeamChannel') }

  describe "PATCH /games/:id/report" do
    before do
      Participation.update_all(aasm_state: 'scheduled')
    end

    it "stores the result and transitions the participation to finished" do
      stub_const('TeamChannel', team_channel_spy)

      patch "/games/#{game.id}/report", params: '{"result": 4}', headers: { "Authorization" => "Bearer #{member.token}", "Content-Type" => "application/vnd.api+json" }
      expect(response).to have_http_status(200)

      team_participation = Team.find(team.id).participations.first
      expect(team_participation.result).to eq(4)
      expect(team_participation).to be_finished

      expect(team_channel_spy).to have_received(:broadcast_to).once.with(other_team, anything)
      expect(team_channel_spy).not_to have_received(:broadcast_to).with(team, anything)
    end
  end
end