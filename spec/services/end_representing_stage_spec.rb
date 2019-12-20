RSpec.describe EndRepresentingStage do
  let(:team) { Team.create }

  let!(:member_1) { Member.create(team: team) }
  let!(:member_2) { Member.create(team: team) }

  let(:incarnation) { Incarnation.create!(duration: 30) }
  let!(:game) { Game.create(incarnation: incarnation, teams: [team])}

  let(:team_channel_spy) { class_spy('TeamChannel') }

  subject do
    described_class.new(game).call
    game.reload
    game
  end

  before do
    Participation.all.each{|p| p.invite && p.accept && p.converge && p.arrive && p.represent! }

    stub_const('TeamChannel', team_channel_spy)
  end

  context "when the game is already scheduled" do
    let(:begins_at) { Time.new(2010) }

    before do
      game.begins_at = begins_at
      game.save
    end

    it "does nothing" do
      expect(subject.begins_at).to eql(begins_at)

      expect(team_channel_spy).not_to have_received(:broadcast_to)
    end
  end

  context "when one member is representing" do
    before do
      Representation.find_by(member: member_1).update(representing: true)
    end

    it "leaves the representations alone and schedules the game" do
      expect(subject.begins_at).not_to be_nil
      expect(Representation.find_by(member: member_1).representing).to be true
      expect(Representation.find_by(member: member_2).representing).to be false

      expect(team_channel_spy).to have_received(:broadcast_to).with(team, anything)
    end
  end

  it "picks a member and schedules the game" do
    expect(subject.begins_at).not_to be_nil
    expect(Representation.pluck(:representing)).to contain_exactly( true, false )

    expect(team_channel_spy).to have_received(:broadcast_to).with(team, anything)
  end
end
