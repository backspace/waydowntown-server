require 'rails_helper'

RSpec.describe "Games", type: :request do
  describe "POST /games" do
    let(:team) { Team.create(name: 'us') }

    it "finds a game" do
      finder = double
      game = double("Game", id: '123', name: "a game name")
      allow(finder).to receive(:call).and_return([game])

      allow(FindGames).to receive(:new).with(team).and_return(finder)

      post '/games/request', headers: { "Authorization" => "Bearer #{team.token}" }
      expect(response).to have_http_status(200)
      expect_attributes name: "a game name"
    end
  end
end
