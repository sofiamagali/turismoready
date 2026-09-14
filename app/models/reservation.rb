class Reservation < ApplicationRecord
  STATUSES = %w[pending awaiting_payment paid cancelled].freeze
  STATUS_LABELS = {
    "pending" => "Pendiente",
    "awaiting_payment" => "Esperando pago",
    "paid" => "Pagada",
    "cancelled" => "Cancelada"
  }.freeze

  belongs_to :user
  belongs_to :trip
  has_many :passengers, dependent: :destroy, inverse_of: :reservation

  accepts_nested_attributes_for :passengers

  validates :status, inclusion: { in: STATUSES }
  validates :reservation_code, presence: true, uniqueness: true
  validates :total_price, numericality: { greater_than: 0 }
  validate :must_have_passengers
  validate :passengers_must_fit_available_slots

  before_validation :set_defaults, on: :create
  before_validation :calculate_total
  around_save :reserve_capacity

  def editable?
    !paid? && !cancelled?
  end

  def status_label
    STATUS_LABELS[status]
  end

  def pending?
    status == "pending"
  end

  def awaiting_payment?
    status == "awaiting_payment"
  end

  def paid?
    status == "paid"
  end

  def cancelled?
    status == "cancelled"
  end

  private

  def set_defaults
    self.status ||= "pending"
    self.reservation_code ||= generate_unique_code
  end

  def calculate_total
    self.total_price = trip.price * passengers.size if trip.present? && passengers.any?
  end

  def generate_unique_code
    loop do
      code = "RES-#{SecureRandom.alphanumeric(6).upcase}"
      return code unless self.class.exists?(reservation_code: code)
    end
  end

  def must_have_passengers
    errors.add(:passengers, "debe incluir al menos uno") if passengers.empty?
  end

  def passengers_must_fit_available_slots
    return if trip.blank? || cancelled?
    unless trip.active? && trip.destination.active? && trip.start_date >= Date.current
      errors.add(:trip, "no está disponible para reservas") if new_record?
    end
    return if passengers.size <= trip.remaining_slots + previous_passenger_count

    errors.add(:passengers, "supera los cupos disponibles")
  end

  def previous_passenger_count
    return 0 if new_record? || status_in_database == "cancelled"

    Passenger.where(reservation_id: id).count
  end

  def reserve_capacity
    trip.destination.with_lock do
      trip.with_lock do
        difference = (cancelled? ? 0 : passengers.size) - previous_passenger_count
        if difference.positive? && (!trip.bookable? || difference > trip.remaining_slots)
          errors.add(:passengers, "supera los cupos disponibles; viaje completo o no disponible")
          raise ActiveRecord::RecordInvalid, self
        end
        yield
        trip.update!(available_slots: trip.available_slots - difference) unless difference.zero?
        if trip.shared_capacity? && !difference.zero?
          trip.destination.update!(shared_bus_slots: trip.destination.shared_bus_slots - difference)
        end
      end
    end
  end
end
