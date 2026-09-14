class Trip < ApplicationRecord
  TRANSPORT_TYPES = { "bus" => "Micro", "airplane" => "Avión" }.freeze

  scope :upcoming, -> { where(active: true).where("start_date >= ?", Date.current) }

  validates :transport_type, inclusion: { in: TRANSPORT_TYPES.keys }

  def transport_type_label
    TRANSPORT_TYPES[transport_type]
  end

  BOARD_TYPES = {
    "none" => "Sin pensión",
    "breakfast" => "Desayuno",
    "half_board" => "Media pensión",
    "full_board" => "Pensión completa"
  }.freeze

  belongs_to :destination
  has_many :reservations, dependent: :restrict_with_error

  validates :name, :start_date, :end_date, presence: true
  validates :price, numericality: { greater_than: 0 }
  validates :available_slots, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :board_type, inclusion: { in: BOARD_TYPES.keys }
  validate :start_must_precede_end

  def self.board_type_options
    BOARD_TYPES.map { |value, label| [label, value] }
  end

  def board_type_label
    BOARD_TYPES[board_type]
  end

  def shared_capacity?
    transport_type == "bus" && source_url.present? && destination.shared_bus_slots.present?
  end

  def remaining_slots
    shared_capacity? ? [available_slots, destination.shared_bus_slots].min : available_slots
  end

  def bookable?
    active? && destination.active? && start_date >= Date.current && remaining_slots.positive?
  end

  private

  def start_must_precede_end
    return if start_date.blank? || end_date.blank?
    return if start_date < end_date

    errors.add(:start_date, "debe ser anterior a la fecha de fin")
  end
end
