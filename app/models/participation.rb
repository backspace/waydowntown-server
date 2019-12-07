class Participation < ApplicationRecord
  include AASM

  belongs_to :game
  belongs_to :team

  aasm do
    state :unsent, initial: true
    state :invited, :accepted, :converging, :arrived, :scheduled, :finished
    state :cancelled, :dismissed

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

    event :finish do
      transitions from: :scheduled, to: :finished
    end

    event :cancel do
      transitions from: [:invited, :accepted], to: :cancelled
      transitions from: :unsent, to: :dismissed
    end
  end
end
