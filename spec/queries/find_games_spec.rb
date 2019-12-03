RSpec.describe FindGames do
  let(:requesting_team) { Team.create(name: 'us') }

  subject { described_class.new(requesting_team).call() }

  context 'with an existing game' do
    let!(:played_team) { Team.create(name: 'played') }
    let!(:other_team) { Team.create(name: 'them') }

    let(:played_incarnation) { Incarnation.create }
    let!(:played_game) { Game.create(incarnation: played_incarnation, teams: [requesting_team, played_team]) }

    let!(:unplayed_incarnation) { Incarnation.create }

    it 'returns possible games with possible concept overlap' do
      expect(subject).not_to include( have_attributes(incarnation: played_incarnation) )

      expect(subject).to include( have_attributes(incarnation: unplayed_incarnation, teams: [requesting_team, played_team] ) )
      expect(subject).to include( have_attributes(incarnation: unplayed_incarnation, teams: [requesting_team, other_team] ) )
    end
  end
end
