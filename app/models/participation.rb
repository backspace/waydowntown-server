class Participation < ApplicationRecord
  include AASM

  belongs_to :game
  belongs_to :team

  has_many :representations

  aasm do
    state :unsent, initial: true
    state :invited, :accepted, :converging, :arrived, :representing, :scheduled, :finished, :archived
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

    event :represent do
      transitions from: :arrived, to: :representing, after: Proc.new { team.members.each {|member| representations.create(member: member) } }
    end

    event :schedule do
      transitions from: :representing, to: :scheduled, guard: :all_representations_determined?
    end

    event :finish do
      transitions from: :scheduled, to: :finished
    end

    event :archive do
      transitions from: :finished, to: :archived
    end

    event :cancel do
      transitions from: [:invited, :accepted], to: :cancelled
      transitions from: :unsent, to: :dismissed
    end

    event :dismiss do
      transitions from: :cancelled, to: :dismissed
    end
  end

  protected def all_representations_determined?
    representations.where(representing: nil).empty?
  end
end
