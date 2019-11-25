require 'rails_helper'

RSpec.describe "Games", type: :request do
  describe "POST /games" do
    let(:team) { Team.create(name: 'us') }
    let(:other_team) { Team.create(name: 'them') }

    let(:game) { Game.create(incarnation: incarnation, teams: [team, other_team]) }
    let(:incarnation) { Incarnation.create(concept: concept) }
    let(:concept) { Concept.create(name: 'a concept') }

    it "finds a game" do
      finder = double
      allow(finder).to receive(:call).and_return([game])

      allow(FindGames).to receive(:new).with(team).and_return(finder)

      post '/games/request', headers: { "Authorization" => "Bearer #{team.token}" }
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

      # FIXME this doesn’t work, despite the record being there?
      # expect_record concept, included: true
    end
  end
end
