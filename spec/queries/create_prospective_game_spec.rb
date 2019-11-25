RSpec.describe CreateProspectiveGame do
  let(:requesting_team) { Team.create(name: 'us') }
  let(:other_team) { Team.create(name: 'them') }

  let(:concept) { Concept.create }
  let(:incarnation) { Incarnation.create(concept: concept) }
  let(:game) { Game.new(teams: [requesting_team, other_team], incarnation: incarnation) }

  subject { described_class.new(requesting_team, game).call() }

  it 'saves the game with the initiator set' do
    expect(subject).not_to be_new_record
    expect(subject.participations).to include( have_attributes(team: requesting_team, initiator: true) )
    expect(subject.participations).to include( have_attributes(team: other_team, initiator: false) )
  end
end
