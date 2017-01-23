class User < ApplicationRecord
  has_many :posts
  has_many :sessions, dependent: :destroy

  has_secure_password

  validates :username, presence: true
end
