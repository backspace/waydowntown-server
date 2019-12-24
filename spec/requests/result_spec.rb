require 'rails_helper'

RSpec.describe "Result", type: :request do

  let!(:member) { Member.create(name: 'me', team: team) }
  let!(:other_member) { Member.create(team: team) }
  let(:team) { Team.create(name: 'us') }
  let!(:other_team) { Team.create(name: 'them') }

  let!(:game) { Game.create(incarnation: incarnation, teams: [team, other_team]) }
  let(:incarnation) { Incarnation.create }

  let(:team_channel_spy) { class_spy('TeamChannel') }

  describe "PATCH /games/:id/report" do
    before do
      Participation.update_all(aasm_state: 'scheduled')
      Participation.all.each do |participation|
        participation.team.members.each do |member|
          participation.representations.create!(member: member)
        end
      end
    end

    it "returns a 403" do
      stub_const('TeamChannel', team_channel_spy)

      patch "/games/#{game.id}/report", params: '{"value": 4}', headers: { "Authorization" => "Bearer #{member.token}", "Content-Type" => "application/vnd.api+json" }
      expect(response).to have_http_status(403)

      expect(team_channel_spy).not_to have_received(:broadcast_to)
    end

    context "and only the submitting member is representing" do
      before do
        member.representations.update(representing: true)
      end

      it "stores the result and transitions the participation to scoring but does not queue the scorer" do
        stub_const('TeamChannel', team_channel_spy)

        patch "/games/#{game.id}/report", params: '{"value": 4}', headers: { "Authorization" => "Bearer #{member.token}", "Content-Type" => "application/vnd.api+json" }
        expect(response).to have_http_status(200)

        team_participation = Team.find(team.id).participations.first
        expect(team_participation).to be_scoring

        member_representation = Representation.find_by(member: member)
        expect(member_representation.result).to eq({ "value" => 4 })

        expect(team_channel_spy).to have_received(:broadcast_to).once.with(other_team, anything)
        expect(team_channel_spy).to have_received(:broadcast_to).once.with(team, anything)

        expect(ScorerJob).not_to have_been_enqueued.with(game)
      end

      it "can store multiple values" do
        stub_const('TeamChannel', team_channel_spy)

        patch "/games/#{game.id}/report", params: '{"values": [4, 5]}', headers: { "Authorization" => "Bearer #{member.token}", "Content-Type" => "application/vnd.api+json" }
        expect(response).to have_http_status(200)

        member_representation = Representation.find_by(member: member)
        expect(member_representation.result).to eq({ "values" => [4, 5] })
      end

      context "and the other participation is scoring" do
        before do
          other_team.participations.update(aasm_state: "scoring")
        end

        it "queues the scorer" do
          stub_const('TeamChannel', team_channel_spy)
          patch "/games/#{game.id}/report", params: '{"value": 4}', headers: { "Authorization" => "Bearer #{member.token}", "Content-Type" => "application/vnd.api+json" }
          expect(ScorerJob).to have_been_enqueued.with(game)
        end
      end
    end

    context "when both members are representing" do
      before do
        Representation.update(representing: true)
      end

      it "stores the result but does not change the participation state" do
        stub_const('TeamChannel', team_channel_spy)

        patch "/games/#{game.id}/report", params: '{"value": 4}', headers: { "Authorization" => "Bearer #{member.token}", "Content-Type" => "application/vnd.api+json" }
        expect(response).to have_http_status(200)

        team_participation = Team.find(team.id).participations.first
        expect(team_participation).to be_scheduled

        member_representation = Representation.find_by(member: member)
        expect(member_representation.result).to eq({ "value" => 4 })

        expect(team_channel_spy).not_to have_received(:broadcast_to)
      end

      context "and the other member has reported a result" do
        before do
          other_member.representations.update(result: {value: 5})
        end

        it "stores the result and transitions the participation to scoring" do
          stub_const('TeamChannel', team_channel_spy)

          patch "/games/#{game.id}/report", params: '{"value": 4}', headers: { "Authorization" => "Bearer #{member.token}", "Content-Type" => "application/vnd.api+json" }
          expect(response).to have_http_status(200)

          team_participation = Team.find(team.id).participations.first
          expect(team_participation).to be_scoring

          member_representation = Representation.find_by(member: member)
          expect(member_representation.result).to eq({ "value" => 4 })

          expect(team_channel_spy).to have_received(:broadcast_to).once.with(other_team, anything)
          expect(team_channel_spy).to have_received(:broadcast_to).once.with(team, anything)
        end
      end
    end

    context "when the participation is not scheduled" do
      before do
        team.participations.update(aasm_state: "invited")
      end

      it "returns a 409" do
        stub_const('TeamChannel', team_channel_spy)

        patch "/games/#{game.id}/report", params: '{"value": 4}', headers: { "Authorization" => "Bearer #{member.token}", "Content-Type" => "application/vnd.api+json" }
        expect(response).to have_http_status(409)

        expect(team_channel_spy).not_to have_received(:broadcast_to)
      end
    end
  end
end
