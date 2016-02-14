class SupportMailer < ApplicationMailer
  default to: ["david@ladowitz.com"]
  # layout "user_mailer"  # css is not showing up properly when using a layout

  def contact_us_email(options)
    @options = options
    # attachments.inline['logo_handwriting.png'] = File.read('app/assets/images/logo_handwriting.png')

    mail(subject: "#{project_name} - Someone Needs Support")
  end
end
