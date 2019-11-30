require 'rails_helper'

RSpec.describe "Games", type: :request do
  let(:member) { Member.create(name: 'me', team: team) }
  let(:team) { Team.create(name: 'us') }
  let(:other_team) { Team.create(name: 'them') }

  let!(:game) { Game.create(incarnation: incarnation, teams: [team, other_team]) }
  let(:incarnation) { Incarnation.create(concept: concept) }
  let(:concept) { Concept.create(name: 'a concept') }

  let(:team_channel_spy) { class_spy('TeamChannel') }

  describe "GET /games" do
    let!(:other_game) { Game.create(incarnation: incarnation) }

    it "finds the games for the current team" do
      get '/games', headers: { "Authorization" => "Bearer #{member.token}" }
      expect(response).to have_http_status(200)

      expect_record game, type: 'game'
      expect_item_count 1
    end
  end

  describe "POST /games" do
    it "finds a game and temporarily notifies invitees" do
      stub_const('TeamChannel', team_channel_spy)

      finder = double
      allow(finder).to receive(:call).and_return([game])

      allow(FindGames).to receive(:new).with(team).and_return(finder)

      post '/games/request', headers: { "Authorization" => "Bearer #{member.token}" }
      expect(response).to have_http_status(200)

      expect_relationship key: 'incarnation',
        type: 'incarnation',
        id: incarnation.id.to_s,
        included: true

      Participation.all.each do |participation|
        expect_json('data.relationships.participations.data.?', type: 'participation', id: participation.id.to_s)
      end

      # FIXME why is this so painful; neither jsonapi_expectations nor Airborne supports what I need it seems
      json_result = JSON.parse(response.body)
      included_initiator_participation = json_result["included"].find{|included| included["type"] == "participation" && included["attributes"]["initiator"]}

      expect(included_initiator_participation["relationships"]["team"]["data"]["id"]).to eq(team.id.to_s)
      expect(included_initiator_participation["attributes"]["state"]).to eq("invited")

      expect_json('included.?', type: 'concept', id: concept.id.to_s)
      expect_json('included.?', type: 'team', id: team.id.to_s)
      expect_json('included.?', type: 'team', id: other_team.id.to_s)

      expect(team_channel_spy).not_to have_received(:broadcast_to)
    end
  end

  describe "PATCH /games/:id/accept" do
    let(:another_team) { Team.create }
    let!(:another_participation) { Participation.create(team: another_team, game: game, aasm_state: "accepted") }

    before do
      team.participations.each{|p| p.invite! }
    end

    it "accepts a requested game and invites unsent participations" do
      stub_const('TeamChannel', team_channel_spy)

      patch "/games/#{game.id}/accept", headers: { "Authorization" => "Bearer #{member.token}" }
      expect(response).to have_http_status(200)


      json_result = JSON.parse(response.body)

      participations = json_result["included"].select{|included| included["type"] == "participation"}

      team_participation = participations.find{|included| included["id"] == team.participations.first.id.to_s}
      expect(team_participation["attributes"]["state"]).to eq("accepted")

      other_team_participation = participations.find{|included| included["id"] == other_team.participations.first.id.to_s}
      expect(other_team_participation["attributes"]["state"]).to eq("invited")

      another_team_participation = participations.find{|included| included["id"] == another_participation.id.to_s}
      expect(another_team_participation["attributes"]["state"]).to eq("accepted")

      expect(team_channel_spy).to have_received(:broadcast_to).once.with(other_team, anything)
      expect(team_channel_spy).not_to have_received(:broadcast_to).with(team, anything)
    end

    context "when all other participations have been accepted" do
      before do
        other_team.participations.first.invite!
        other_team.participations.first.accept!
      end

      it "moves participations to rendezvousing and notifies other teams" do
        stub_const('TeamChannel', team_channel_spy)

        patch "/games/#{game.id}/accept", headers: { "Authorization" => "Bearer #{member.token}" }
        expect(response).to have_http_status(200)

        json_result = JSON.parse(response.body)
        expect(json_result["included"].select{|i| i["type"] == "participation"}.map{|p| p["attributes"]["state"]}).to all(eq("rendezvousing"))

        expect(team_channel_spy).to have_received(:broadcast_to).once.with(other_team, anything)
        expect(team_channel_spy).not_to have_received(:broadcast_to).with(team, anything)
      end
    end
  end

  describe "PATCH /games/:id/rendezvous" do
    let(:another_team) { Team.create }
    let!(:another_participation) { Participation.create(team: another_team, game: game, aasm_state: "rendezvousing") }

    before do
      team.participations.each{|p| p.invite && p.accept && p.rendezvous! }
      other_team.participations.first.invite!
      other_team.participations.first.accept!
      other_team.participations.first.rendezvous!
    end

    it "rendezvouses and notifies other participators" do
      stub_const('TeamChannel', team_channel_spy)

      patch "/games/#{game.id}/rendezvous", headers: { "Authorization" => "Bearer #{member.token}" }
      expect(response).to have_http_status(200)


      json_result = JSON.parse(response.body)

      participations = json_result["included"].select{|included| included["type"] == "participation"}

      team_participation = participations.find{|included| included["id"] == team.participations.first.id.to_s}
      expect(team_participation["attributes"]["state"]).to eq("rendezvoused")

      other_team_participation = participations.find{|included| included["id"] == other_team.participations.first.id.to_s}
      expect(other_team_participation["attributes"]["state"]).to eq("rendezvousing")

      another_team_participation = participations.find{|included| included["id"] == another_participation.id.to_s}
      expect(another_team_participation["attributes"]["state"]).to eq("rendezvousing")

      expect(team_channel_spy).to have_received(:broadcast_to).once.with(other_team, anything)
      expect(team_channel_spy).not_to have_received(:broadcast_to).with(team, anything)
    end

    context "when all other participations have been rendezvoused" do
      before do
        another_participation.do_rendezvous! # FIXME obvs these names are out of control
        other_team.participations.first.do_rendezvous!
      end

      it "moves participations to scheduled and notifies other teams" do
        stub_const('TeamChannel', team_channel_spy)

        patch "/games/#{game.id}/rendezvous", headers: { "Authorization" => "Bearer #{member.token}" }
        expect(response).to have_http_status(200)

        json_result = JSON.parse(response.body)
        expect(json_result["included"].select{|i| i["type"] == "participation"}.map{|p| p["attributes"]["state"]}).to all(eq("scheduled"))

        expect(team_channel_spy).to have_received(:broadcast_to).once.with(other_team, anything)
        expect(team_channel_spy).not_to have_received(:broadcast_to).with(team, anything)
      end
    end
  end
end
