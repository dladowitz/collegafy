module ApplicationHelper
  def project_name
    Rails.application.config.project_name
  end

  def mail_domain
    Rails.application.config.mail_domain
  end

  def project_description
    Rails.application.config.project_description
  end
end
