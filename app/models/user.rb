class User < ApplicationRecord
  attr_accessor :remember_token

  before_save :downcase_email

  validates :name, presence: true,
    length: {maximum: Settings.validates.name_max_length}

  validates :email, presence: true,
    length: {minimum: Settings.validates.email_min_length,
             maximum: Settings.validates.email_max_length},
    format: {with: Settings.regex.email_regex},
    uniqueness: {case_sensitive: false}

  validates :password, presence: true,
    length: {minimum: Settings.validates.password_min_length},
    if: :password

  has_secure_password

  class << self
    def new_token
      SecureRandom.urlsafe_base64
    end

    def digest string
      check = ActiveModel::SecurePassword.min_cost
      cost = check ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
      BCrypt::Password.create(string, cost:)

    end
  end

  def remember
    self.remember_token = User.new_token
    update remember_digest: User.digest(remember_token)
  end

  def authenticated? remember_token
    BCrypt::Password.new(remember_digest).is_password? remember_token
  end

  def forget
    update_attribute :remember_digest, nil
  end

  private
  def downcase_email
    email.downcase!
  end
end
