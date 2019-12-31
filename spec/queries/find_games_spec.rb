RSpec.describe FindGames do
  let(:requesting_member) { Member.create(capabilities: {"bluetooth" => true, "speed" => true}) }
  let(:requesting_team) { Team.create(name: 'us', members: [requesting_member]) }

  subject { described_class.new(requesting_team).call() }

  context 'with an existing game' do
    let(:played_member) { Member.create(capabilities: {"bluetooth" => true, "speed" => true}) }
    let!(:played_team) { Team.create(name: 'played', members: [played_member]) }

    let(:other_member) { Member.create(capabilities: {"bluetooth" => true, "speed" => true}) }
    let!(:other_team) { Team.create(name: 'them', members: [other_member]) }

    let(:missing_capabilities_member) { Member.create(capabilities: {"bluetooth" => false}) }
    let!(:missing_capabilities_team) { Team.create(members: [missing_capabilities_member] ) }

    let(:played_incarnation) { Incarnation.create(concept_id: "bluetooth-collector") }
    let!(:played_game) { Game.create(incarnation: played_incarnation, teams: [requesting_team, played_team]) }

    let!(:unplayed_incarnation) { Incarnation.create(concept_id: "bluetooth-collector") }

    let!(:missing_concept_capabilities_incarnation) { Incarnation.create(concept_id: "magnetometer-magnitude") }
    let!(:missing_capabilities_incarnation) { Incarnation.create(concept_id: "multiple-choice", capabilities: ["magnetometer"]) }

    it 'returns possible games with possible concept overlap' do
      expect(subject).not_to include( have_attributes(incarnation: played_incarnation) )
      expect(subject).not_to include( have_attributes(incarnation: missing_concept_capabilities_incarnation) )
      expect(subject).not_to include( have_attributes(incarnation: missing_capabilities_incarnation) )

      expect(subject).to include( have_attributes(incarnation: unplayed_incarnation, teams: [requesting_team, played_team] ) )
      expect(subject).to include( have_attributes(incarnation: unplayed_incarnation, teams: [requesting_team, other_team] ) )

      expect(subject).not_to include( have_attributes(incarnation: unplayed_incarnation, teams: [requesting_team, missing_capabilities_team] ) )
    end
  end
end
