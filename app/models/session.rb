require 'securerandom'

class Session < ApplicationRecord
  belongs_to :user

  validates :token, presence: true

  after_initialize :set_token

  private

    def set_token
      return unless token.blank?
      self.token = SecureRandom.urlsafe_base64
    end
end
