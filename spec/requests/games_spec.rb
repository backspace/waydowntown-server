require 'rails_helper'

RSpec.describe "Games", type: :request do
  describe "POST /games" do
    let(:team) { Team.create(name: 'us') }

    let(:game) { Game.create(incarnation: incarnation) }
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

      # FIXME this doesn’t work, despite the record being there?
      # expect_record concept, included: true
    end
  end
end
