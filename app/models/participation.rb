class Participation < ApplicationRecord
  include AASM

  belongs_to :game
  belongs_to :team

  aasm do
    state :unsent, initial: true
    state :invited, :accepted, :rendezvousing, :rendezvoused, :scheduled

    event :invite do
      transitions from: [:unsent, :invited], to: :invited
    end

    event :accept do
      transitions from: [:invited, :accepted], to: :accepted
    end

    event :rendezvous do
      transitions from: :accepted, to: :rendezvousing
    end

    event :do_rendezvous do
      transitions from: :rendezvousing, to: :rendezvoused
    end

    event :schedule do
      transitions from: :rendezvoused, to: :scheduled
    end
  end
end
