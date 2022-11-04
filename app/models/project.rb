class Project < ApplicationRecord
    has_one :tier

    attribute :name, :string
    attribute :description, :string
    attribute :stories, :string, array: true
    attribute :optionals, :string, array: true
    attribute :resources, :string, array: true
    attribute :examples, :string, array: true
end
