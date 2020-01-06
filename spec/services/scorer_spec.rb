RSpec.describe Scorer do
  let(:game) { Game.create(incarnation: incarnation) }
  let(:incarnation) { Incarnation.new(concept_id: "tap") }

  let(:team1) { Team.create(members: [member1a, member1b] )}
  let!(:team1_participation) { game.participations.create(team: team1, aasm_state: "scoring") }

  let(:member1a) { Member.create }
  let!(:member1a_representation) { team1_participation.representations.create(member: member1a) }

  let(:member1b) { Member.create }
  let!(:member1b_representation) { team1_participation.representations.create(member: member1b) }


  let(:team2) { Team.create(members: [member2] )}
  let!(:team2_participation) { game.participations.create(team: team2, aasm_state: "scoring") }

  let(:member2) { Member.create }
  let!(:member2_representation) { team2_participation.representations.create(member: member2) }


  let(:team3) { Team.create(members: [member3] )}
  let!(:team3_participation) { game.participations.create(team: team3, aasm_state: "scoring") }

  let(:member3) { Member.create }
  let!(:member3_representation) { team3_participation.representations.create(member: member3) }

  let(:team_channel_spy) { class_spy('TeamChannel') }

  subject { described_class.new(game).call }

  before do
    stub_const('TeamChannel', team_channel_spy)
  end

  context "when each team has only one representing member" do
    before do
      member1a_representation.update(representing: true)
      member2_representation.update(representing: true)
      member3_representation.update(representing: true)
    end

    context "and one member’s result has a higher value" do
      before do
        member1a_representation.update(result: { "value" => 5 })
        member2_representation.update(result: { "value" => 4 })
        member3_representation.update(result: { "value" => 4 })
      end

      it "declares that member’s team the winner" do
        expect(subject.winners).to contain_exactly( team1 )
      end

      it "marks all participations finished" do
        expect(subject.participations).to all ( be_finished )
      end

      it "stores the score for each participation" do
        subject

        expect(team1_participation[:score]).to eq(5)
        expect(team2_participation[:score]).to eq(4)
        expect(team3_participation[:score]).to eq(4)
      end

      it "channels the results" do
        subject

        expect(team_channel_spy).to have_received(:broadcast_to).once.with(team1, anything)
        expect(team_channel_spy).to have_received(:broadcast_to).once.with(team2, anything)
        expect(team_channel_spy).to have_received(:broadcast_to).once.with(team3, anything)
      end
    end

    context "and two members have the same result" do
      before do
        member1a_representation.update(result: { "value" => 5 })
        member2_representation.update(result: { "value" => 5 })
        member3_representation.update(result: { "value" => 4 })
      end

      it "declares those members’s teams the winners" do
        expect(subject.winners).to contain_exactly( team1, team2 )
      end
    end

    context "and the incarnation scores using most matches" do
      let(:incarnation) { Incarnation.create(concept_id: "word-finder", goal: {"values" => ["A", "B", "C"] })}

      context "and one team’s member has the most matches" do
        before do
          member1a_representation.update(result: { "values" => ["C", "B"] })
          member2_representation.update(result: { "values" => ["A"] })
          member3_representation.update(result: { "values" => ["X", "B"] })
        end

        it "declares that member’s team the winner" do
          expect(subject.winners).to contain_exactly( team1 )
        end

        it "stores the score for each participation" do
          subject

          expect(team1_participation[:score]).to eq(2)
          expect(team2_participation[:score]).to eq(1)
          expect(team3_participation[:score]).to eq(1)
        end

        it "stores the matches for each participation" do
          subject

          expect(member1a_representation.result["matches"]).to contain_exactly("C", "B")
          expect(member2_representation.result["matches"]).to contain_exactly("A")
          expect(member3_representation.result["matches"]).to contain_exactly("B")
        end
      end
    end

    context "and the incarnation scores using closest" do
      let(:incarnation) { Incarnation.create(concept_id: "enumerator", goal: {"value" => 1312 })}

      context "and one team’s member is closest" do
        before do
          member1a_representation.update(result: { "value" => 1311 })
          member2_representation.update(result: { "value" => 1300 })
          member3_representation.update(result: { "value" => 1401 })
        end

        it "declares that member’s team the winner" do
          expect(subject.winners).to contain_exactly( team1 )
        end

        it "stores the score for each participation" do
          subject

          expect(team1_participation[:score]).to eq(1)
          expect(team2_participation[:score]).to eq(12)
          expect(team3_participation[:score]).to eq(89)
        end
      end
    end
  end

  context "when a team has more than one representing member" do
    before do
      member1a_representation.update(representing: true, result: { "value" => 9 })
      member1b_representation.update(representing: true, result: { "value" => 3 })
      member2_representation.update(representing: true, result: { "value" => 5 })
      member3_representation.update(representing: true, result: { "value" => 5 })
    end

    it "averages the results across the team" do
      expect(subject.winners).to contain_exactly( team1 )

      expect(team1_participation[:score]).to eq(6)
    end
  end
end
