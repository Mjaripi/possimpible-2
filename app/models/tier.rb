class Tier < ApplicationRecord
    belongs_to :Project

    attribute :value, :integer
    attribute :description, :string
end
