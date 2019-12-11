RSpec.describe Scheduler do
  include ActiveSupport::Testing::TimeHelpers

  let(:game) { Game.new(incarnation: incarnation) }
  let(:incarnation) { Incarnation.new(concept_id: "tap") }

  subject { described_class.new(game).schedule }

  before do
    freeze_time
  end

  after do
    travel_back
  end

  it 'schedules the game with tap’s duration' do
    expect(subject).to have_attributes(
      begins_at: Time.current + 30.seconds,
      ends_at: Time.current + 40.seconds
    )
  end

  context 'with a concept with a different duration' do
    let(:incarnation) { Incarnation.new(concept_id: "bluetooth-collector") }

    it 'schedules the game with the different duration' do
      expect(subject).to have_attributes(
        begins_at: Time.current + 30.seconds,
        ends_at: Time.current + 45.seconds
      )
    end
  end

  context 'with an incarnation whose duration is overridden' do
    let(:incarnation) { Incarnation.new(concept_id: "tap", duration: 30) }

    it 'schedules the game with the different duration' do
      expect(subject).to have_attributes(
        begins_at: Time.current + 30.seconds,
        ends_at: Time.current + 60.seconds
      )
    end
  end
end
