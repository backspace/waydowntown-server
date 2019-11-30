class Participation < ApplicationRecord
  include AASM

  belongs_to :game
  belongs_to :team

  aasm do
    state :unsent, initial: true
    state :invited, :accepted, :converging, :arrived, :scheduled

    event :invite do
      transitions from: [:unsent, :invited], to: :invited
    end

    event :accept do
      transitions from: [:invited, :accepted], to: :accepted
    end

    event :converge do
      transitions from: :accepted, to: :converging
    end

    event :arrive do
      transitions from: :converging, to: :arrived
    end

    event :schedule do
      transitions from: :arrived, to: :scheduled
    end
  end
end
