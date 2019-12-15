require 'rails_helper'

RSpec.describe "Games", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let!(:member) { Member.create(name: 'me', team: team) }
  let!(:team) { Team.create(name: 'us') }

  let!(:other_team_member) { Member.create(name: 'other', team: other_team) }
  let(:other_team) { Team.create(name: 'them') }

  let!(:game) { Game.create(incarnation: incarnation, teams: [team, other_team]) }
  let(:incarnation) { Incarnation.create(concept_id: "tap") }

  let(:team_channel_spy) { class_spy('TeamChannel') }
  let(:notifier_spy) { class_spy('Notifier')}

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

    it "creates a game with requested relationships" do
      stub_const('TeamChannel', team_channel_spy)

      post '/games/request', params: { concept_id: "tap", team_id: other_team.id }, headers: { "Authorization" => "Bearer #{member.token}" }
      expect(response).to have_http_status(201)

      game = Game.last
      expect(game.incarnation.concept_id).to eq("tap")
      expect(game.teams).to eq([team, other_team])
    end

    it "creates a solo game with requested concept" do
      stub_const('TeamChannel', team_channel_spy)

      post '/games/request', params: { concept_id: "tap", }, headers: { "Authorization" => "Bearer #{member.token}" }
      expect(response).to have_http_status(201)

      game = Game.last
      expect(game.incarnation.concept_id).to eq("tap")
      expect(game.teams).to eq([team])
    end
  end

  describe "PATCH /games/:id/accept" do
    let(:another_team) { Team.create }
    let!(:another_participation) { Participation.create(team: another_team, game: game, aasm_state: "accepted") }

    before do
      team.participations.each{|p| p.invite! }
    end

    it "accepts a requested game and invites/notifies unsent participations" do
      stub_const('TeamChannel', team_channel_spy)
      stub_const('Notifier', notifier_spy)

      patch "/games/#{game.id}/accept", headers: { "Authorization" => "Bearer #{member.token}" }
      expect(response).to have_http_status(200)

      expect(Participation.find_by(team: team)).to be_accepted
      expect(Participation.find_by(team: other_team)).to be_invited
      expect(Participation.find_by(team: another_team)).to be_accepted

      expect(team_channel_spy).to have_received(:broadcast_to).once.with(other_team, anything)
      expect(team_channel_spy).not_to have_received(:broadcast_to).with(team, anything)

      expect(notifier_spy).to have_received(:notify).once.with(other_team, "#{team.name} invited you to a game")
      expect(notifier_spy).not_to have_received(:notify).with(another_team, anything)
      expect(notifier_spy).not_to have_received(:notify).with(team, anything)
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

    it "meets and notifies other participants" do
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
      let!(:another_team_member_1) { Member.create(team: another_team) }
      let!(:another_team_member_2) { Member.create(team: another_team) }

      before do
        another_participation.arrive!
        other_team.participations.first.arrive!
      end

      it "moves participations to representing, creates representations, and notifies other teams" do
        stub_const('TeamChannel', team_channel_spy)

        patch "/games/#{game.id}/arrive", headers: { "Authorization" => "Bearer #{member.token}" }
        expect(response).to have_http_status(200)

        expect(Participation.all).to all(be_representing)

        [member, other_team_member, another_team_member_1, another_team_member_2].each_with_index do |m, i|
          representation = Representation.find_by(member: m)
          expect(representation).to be
          expect(representation.representing).to be_nil
          expect(representation.participation.team).to eq(m.team)
        end

        expect(team_channel_spy).to have_received(:broadcast_to).once.with(other_team, anything)
        expect(team_channel_spy).not_to have_received(:broadcast_to).with(team, anything)
      end
    end
  end

  describe "PATCH /games/:id/represent" do
    let(:another_team) { Team.create }
    let!(:another_team_member_1) { Member.create(team: another_team) }
    let!(:another_team_member_2) { Member.create(team: another_team) }
    let!(:another_participation) { Participation.create(team: another_team, game: game, aasm_state: "arrived") }

    before do
      team.participations.each{|p| p.invite && p.accept && p.converge! && p.arrive! && p.represent! }
      other_team.participations.first.invite!
      other_team.participations.first.accept!
      other_team.participations.first.converge!
      other_team.participations.first.arrive!
      other_team.participations.first.represent!

      another_participation.represent!
    end

    it "updates the representation, does not change the participation state, and notifies other participants" do
      stub_const('TeamChannel', team_channel_spy)

      patch "/games/#{game.id}/represent", params: '{"representing": true}', headers: { "Authorization" => "Bearer #{member.token}", "Content-Type" => "application/vnd.api+json" }
      expect(response).to have_http_status(200)

      expect(Representation.find_by(member: member)).to be_representing
      expect(Participation.find_by(team: team)).to be_representing

      expect(Participation.find_by(team: other_team)).to be_representing
      expect(Participation.find_by(team: another_team)).to be_representing

      expect(team_channel_spy).to have_received(:broadcast_to).once.with(other_team, anything)
      expect(team_channel_spy).not_to have_received(:broadcast_to).with(team, anything)
    end

    context "when all other participants have decided on representation" do
      before do
        another_participation.representations.first.update(representing: true)
        another_participation.representations.last.update(representing: false)

        other_team.participations.first.representations.first.update(representing: true)

        freeze_time
      end

      after do
        travel_back
      end

      it "moves participations to scheduled and notifies other teams" do
        stub_const('TeamChannel', team_channel_spy)

        patch "/games/#{game.id}/represent", params: '{"representing": false}', headers: { "Authorization" => "Bearer #{member.token}", "Content-Type" => "application/vnd.api+json" }
        expect(response).to have_http_status(200)

        expect(Participation.all).to all(be_scheduled)

        expect(team_channel_spy).to have_received(:broadcast_to).once.with(other_team, anything)
        expect(team_channel_spy).not_to have_received(:broadcast_to).with(team, anything)

        expect(Game.first.begins_at).to eq(Time.current + 30.seconds)
        expect(Game.first.ends_at).to eq(Time.current + 40.seconds)
      end
    end
  end

  describe "PATCH /games/:id/cancel" do
    let(:another_team) { Team.create }
    let!(:another_participation) { Participation.create(team: another_team, game: game, aasm_state: "accepted") }

    before do
      team.participations.each{|p| p.invite! }
    end

    it "cancels a game and notifies participations" do
      stub_const('TeamChannel', team_channel_spy)

      patch "/games/#{game.id}/cancel", headers: { "Authorization" => "Bearer #{member.token}" }
      expect(response).to have_http_status(200)

      expect(Participation.find_by(team: team)).to be_cancelled
      expect(Participation.find_by(team: other_team)).to be_dismissed
      expect(Participation.find_by(team: another_team)).to be_cancelled

      expect(team_channel_spy).to have_received(:broadcast_to).once.with(other_team, anything)
      expect(team_channel_spy).not_to have_received(:broadcast_to).with(team, anything)
    end
  end

  describe "PATCH /games/:id/dismiss" do
    let(:another_team) { Team.create }
    let!(:another_participation) { Participation.create(team: another_team, game: game, aasm_state: "accepted") }

    before do
      team.participations.update(aasm_state: "cancelled")
    end

    it "dismisses a game and sends no notifications" do
      stub_const('TeamChannel', team_channel_spy)

      patch "/games/#{game.id}/dismiss", headers: { "Authorization" => "Bearer #{member.token}" }
      expect(response).to have_http_status(200)

      expect(Participation.find_by(team: team)).to be_dismissed
      expect(Participation.find_by(team: other_team)).to be_unsent
      expect(Participation.find_by(team: another_team)).to be_accepted

      expect(team_channel_spy).not_to have_received(:broadcast_to)
    end
  end

  describe "PATCH /games/:id/archive" do
    let(:another_team) { Team.create }
    let!(:another_participation) { Participation.create(team: another_team, game: game, aasm_state: "finished") }

    before do
      team.participations.update(aasm_state: "finished")
    end

    it "archives a game and sends no notifications" do
      stub_const('TeamChannel', team_channel_spy)

      patch "/games/#{game.id}/archive", headers: { "Authorization" => "Bearer #{member.token}" }
      expect(response).to have_http_status(200)

      expect(Participation.find_by(team: team)).to be_archived
      expect(Participation.find_by(team: other_team)).to be_unsent
      expect(Participation.find_by(team: another_team)).to be_finished

      expect(team_channel_spy).not_to have_received(:broadcast_to)
    end
  end
end
