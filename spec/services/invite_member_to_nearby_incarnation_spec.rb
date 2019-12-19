RSpec.describe InviteMemberToNearbyIncarnation do
  let(:team) { Team.create }
  let!(:member) { Member.create!(team: team) }

  let(:finder) { double }

  let(:team_channel_spy) { class_spy('TeamChannel') }
  let(:notifier_spy) { class_spy('Notifier')}

  subject { described_class.new(member).call }

  before do
    allow(FindLocatedIncarnations).to receive(:new).with(member).and_return(finder)
    allow(finder).to receive(:call).and_return(located_incarnations)

    stub_const('TeamChannel', team_channel_spy)
    stub_const('Notifier', notifier_spy)
  end

  context "when there are no nearby incarnations" do
    let(:located_incarnations) { [] }

    it "does nothing" do
      subject

      expect(team_channel_spy).not_to have_received(:broadcast_to)
      expect(notifier_spy).not_to have_received(:notify)
    end
  end

  context "when there are nearby incarnations" do
    let(:location) { Location.create(name: "Somewhere" )}
    let(:incarnation_one) { Incarnation.new(concept_id: "tap", location: location) }
    let(:incarnation_two) { Incarnation.new(concept_id: "tap") }

    let(:located_incarnations) { [ incarnation_one, incarnation_two ]}

    it "creates a game for the first incarnation, notifies the team, and sends the game via the channel" do
      subject

      participation = Participation.first

      expect(participation.team).to eql(team)
      expect(participation.game.incarnation).to eql(incarnation_one)

      expect(team_channel_spy).to have_received(:broadcast_to).with(team, anything)
      expect(notifier_spy).to have_received(:notify).once.with(team, "Are you near/in Somewhere? Here’s an invitation")
    end
  end
end
