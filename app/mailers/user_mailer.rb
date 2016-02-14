class UserMailer < ApplicationMailer
  # layout "user_mailer"  # css is not showing up properly when using a layout

  # Set in environment initializers. Can't seem to set this by using #root_url
  RESET_LINK_BASE = "#{Rails.application.config.action_mailer.default_url_options[:host]}/reset_password/"

  def registration_email(registration)
    @registration = registration
    attachments.inline['logo_handwriting.png'] = File.read('app/assets/images/logo_handwriting.png')

    mail(to: @registration.email, subject: "#{project_name} - Registration")
  end

  def signup_email(user)
    @user = user
    # attachments.inline['logo_handwriting.png'] = File.read('app/assets/images/logo_handwriting.png')
    mail(to: @user.email, subject: "#{project_name} - Signup")
  end

  def signup_alert_email(user)
    @user = user

    mail(to: ["david@ladowitz.com"], subject: "#{project_name} - Signup")
  end

  def request_password(user, token)
    @user = user
    @reset_link = RESET_LINK_BASE + token
    attachments.inline['logo_handwriting.png'] = File.read('app/assets/images/logo_handwriting.png')

    mail(to: @user.email, subject: "#{project_name} - Password Reset")
  end
end
