class User < ApplicationRecord
  has_many :reservations, dependent: :restrict_with_error

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :first_name, :last_name, presence: true
  validates :phone,
            format: { with: /\A[\d\s()+.-]+\z/, message: "solo puede incluir números, espacios, +, paréntesis, puntos y guiones" },
            allow_blank: true
end
