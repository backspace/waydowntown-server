require 'rails_helper'

RSpec.describe Member, type: :model do
  let(:team) { Team.create }

  it "rejects extraneous capabilities" do
    expect(Member.new(team: team, capabilities: {"jorts" => "jants"})).to be_invalid
  end

  it "rejects non-boolean capabilities" do
    expect(Member.new(team: team, capabilities: {"bluetooth" => "hello"})).to be_invalid
  end

  it "accepts boolean capabilities" do
    expect(Member.new(team: team, capabilities: {
      "bluetooth" => false,
      "camera" => true,
      "decibels" => false,
      "devicemotion" => false,
      "location" => true,
      "magnetometer" => true,
      "ocr" => true,

      "exertion" => true,
      "height" => false,
      "scents" => false,
      "speed" => true,
      "stairs" => false,

      "fastNavigation" => true,
    })).to be_valid
  end
end
