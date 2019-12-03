require 'rails_helper'

RSpec.describe "Games", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:member) { Member.create(name: 'me', team: team) }
  let(:team) { Team.create(name: 'us') }
  let(:other_team) { Team.create(name: 'them') }

  let!(:game) { Game.create(incarnation: incarnation, teams: [team, other_team]) }
  let(:incarnation) { Incarnation.create }

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
    it "finds a game but sends out no notifications" do
      stub_const('TeamChannel', team_channel_spy)

      finder = double
      allow(finder).to receive(:call).and_return([game])

      allow(FindGames).to receive(:new).with(team).and_return(finder)

      post '/games/request', headers: { "Authorization" => "Bearer #{member.token}" }
      expect(response).to have_http_status(201)

      expect(Participation.find_by(team: team)).to be_initiator
      expect(Participation.find_by(team: other_team)).to_not be_initiator

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

      expect(Participation.find_by(team: team)).to be_accepted
      expect(Participation.find_by(team: other_team)).to be_invited
      expect(Participation.find_by(team: another_team)).to be_accepted

      expect(team_channel_spy).to have_received(:broadcast_to).once.with(other_team, anything)
      expect(team_channel_spy).not_to have_received(:broadcast_to).with(team, anything)
    end

    context "when all other participations have been accepted" do
      before do
        other_team.participations.first.invite!
        other_team.participations.first.accept!
      end

      it "moves participations to converging and notifies other teams" do
        stub_const('TeamChannel', team_channel_spy)

        patch "/games/#{game.id}/accept", headers: { "Authorization" => "Bearer #{member.token}" }
        expect(response).to have_http_status(200)

        expect(Participation.all).to all(be_converging)

        expect(team_channel_spy).to have_received(:broadcast_to).once.with(other_team, anything)
        expect(team_channel_spy).not_to have_received(:broadcast_to).with(team, anything)
      end
    end
  end

  describe "PATCH /games/:id/arrive" do
    let(:another_team) { Team.create }
    let!(:another_participation) { Participation.create(team: another_team, game: game, aasm_state: "converging") }

    before do
      team.participations.each{|p| p.invite && p.accept && p.converge! }
      other_team.participations.first.invite!
      other_team.participations.first.accept!
      other_team.participations.first.converge!
    end

    it "meets and notifies other participators" do
      stub_const('TeamChannel', team_channel_spy)

      patch "/games/#{game.id}/arrive", headers: { "Authorization" => "Bearer #{member.token}" }
      expect(response).to have_http_status(200)

      expect(Participation.find_by(team: team)).to be_arrived
      expect(Participation.find_by(team: other_team)).to be_converging
      expect(Participation.find_by(team: another_team)).to be_converging

      expect(team_channel_spy).to have_received(:broadcast_to).once.with(other_team, anything)
      expect(team_channel_spy).not_to have_received(:broadcast_to).with(team, anything)
    end

    context "when all other participations have arrived" do
      before do
        another_participation.arrive!
        other_team.participations.first.arrive!

        freeze_time
      end

      after do
        travel_back
      end

      it "moves participations to scheduled and notifies other teams" do
        stub_const('TeamChannel', team_channel_spy)

        patch "/games/#{game.id}/arrive", headers: { "Authorization" => "Bearer #{member.token}" }
        expect(response).to have_http_status(200)

        expect(Participation.all).to all(be_scheduled)

        expect(team_channel_spy).to have_received(:broadcast_to).once.with(other_team, anything)
        expect(team_channel_spy).not_to have_received(:broadcast_to).with(team, anything)

        expect(Game.first.begins_at).to eq(Time.current + 30.seconds)
        expect(Game.first.ends_at).to eq(Time.current + 40.seconds)
      end
    end
  end
end
