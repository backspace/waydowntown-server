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

  it "rejects extraneous device fields" do
    expect(Member.new(team: team, device: {"jorts" => "jants"})).to be_invalid
  end

  it "rejects non-string device fields" do
    expect(Member.new(team: team, device: {"jorts" => 1312})).to be_invalid
  end

  it "accepts string device fields" do
    expect(Member.new(team: team, device: {
      "cordova" => "a",
      "model" => "b",
      "platform" => "c",
      "uuid" => "d",
      "version" => "e",
      "manufacturer" => "f",
      "isVirtual" => "g",
      "serial" => "h"
    })).to be_valid
  end
end
