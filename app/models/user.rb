# frozen_string_literal: true

class User < ApplicationRecord
  extend Enumerize

  enumerize :language, in: %i[ruby js], default: :ruby

  has_many :repositories, dependent: :destroy
end
