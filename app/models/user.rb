class User < ApplicationRecord
    #has_one :token, dependent: :destroy
    validates :email, uniqueness: true, presence: true
    validates :password, length: { minimum: 4, allow_nil: true }
    validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

end
