class User < ApplicationRecord
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

  private
  def downcase_email
    email.downcase!
  end
end
