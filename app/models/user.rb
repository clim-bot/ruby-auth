class User < ApplicationRecord
  # Handles authentication and password management
  has_secure_password

  # User can have one to many associations
  has_many :sessions, dependent: :destroy
  # User can have one to many posts
  has_many :posts, dependent: :destroy

  # Ensure email is unique and present
  validates :email_address, presence: true, uniqueness: { case_sensitive: false }
  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
