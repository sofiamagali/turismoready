class Passenger < ApplicationRecord
  belongs_to :reservation, inverse_of: :passengers

  validates :first_name, :last_name, :dni, :birth_date, presence: true
end
