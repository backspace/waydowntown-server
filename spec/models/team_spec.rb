require 'rails_helper'

RSpec.describe Team, type: :model do
  let(:a) { Member.create(capabilities: {"bluetooth" => true, "camera" => false, "location" => true})}
  let(:b) { Member.create(capabilities: {"bluetooth" => true, "camera" => true})}
  let(:team) { Team.create(members: [a, b]) }

  it "merges member capabilities" do
    expect(team.capabilities).to eql({
      "bluetooth" => true,
      "camera" => false,
      "location" => false,
    })
  end

  it "knows whether it can play an incarnation" do
    expect(team.can_play?(Incarnation.new(concept_id: "multiple-choice"))).to be true
    expect(team.can_play?(Incarnation.new(concept_id: "bluetooth-collector"))).to be false
  end
end
