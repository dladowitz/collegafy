class ApplicationMailer < ActionMailer::Base
  # brings in helpers to the mailer classes
  include ApplicationHelper

  # brings in helpers to the view
  helper ApplicationHelper

  default to: ["david@ladowitz.com"]

  #mail_domain doesn't work properly here
  default(from: "admin@#{Rails.application.config.mail_domain}")
end
