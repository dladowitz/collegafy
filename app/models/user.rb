# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  first_name      :string
#  last_name       :string
#  email           :string
#  password_digest :string
#  admin           :boolean
#  created_at      :datetime
#  updated_at      :datetime
#  stripe_id       :string
#

class User < ActiveRecord::Base
  validates :first_name, presence: true
  validates :email,      presence: true, uniqueness: true
  validates :password,   presence: { on: create }, length: { minimum: 6 }, if: :password_digest_changed?

  validate :admin_change, on: :update

  before_validation :downcase_email, :if => Proc.new {|user| user.new_record? }

  has_secure_password
  has_many :password_resets
  has_one :subscription


  ### Instance Methods

  def admin_change
    if self.admin_changed?

      # This doesn't work. Go into rails console and set with:
      # User.first.update_attribute(:admin, true)
      unless User.current_user.id == 1 #needed to allow first user to be made admin in console. Maye just make a method to set the first user as admin
        errors.add(:admin, "state can only be changed by current admin") unless User.current_user.admin?
      end
    end
  end

  def full_name
    "#{first_name.capitalize if first_name} #{last_name.capitalize if last_name}"
  end
  
  def valid_subscription?
    subscription && subscription.level >= 1
  end

  ### Class Methods

  # Not sure how Thread works here, but a guy on the interweb seems to thing its ok:
  # http://clearcove.ca/2008/08/recipe-make-request-environment-available-to-models-in-rails/
  # Used to access current_user in the admin_change method on the model
  def self.current_user
    Thread.current[:user]
  end

  def self.current_user=(user)
    Thread.current[:user] = user
  end

  private

  def downcase_email
    if self.email
      self.email = self.email.downcase
    end
  end
end
