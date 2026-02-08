# frozen_string_literal: true

class Repository::Check < ApplicationRecord
  include AASM

  belongs_to :repository

  aasm column: :status do
    state :new, initial: true
    state :cloning
    state :checking
    state :completed

    event :clone do
      transitions from: :new, to: :cloning
    end

    event :run_check do
      transitions from: :cloning, to: :ckecking
    end

    event :complete_check do
      transitions from: :checking, to: :completed
    end
  end
end
