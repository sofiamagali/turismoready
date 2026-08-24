class Destination < ApplicationRecord
  validates :name, :country, :city, presence: true
end
