class Destination < ApplicationRecord
  has_many :trips, dependent: :restrict_with_error

  validates :name, :country, :city, presence: true
end
