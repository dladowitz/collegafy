class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include ApplicationHelper #brings in helpers/application_helper.rb for use in controllers

  rescue_from CanCan::AccessDenied do |exception|
    flash[:danger] = "You are not authorized for this page. All your bases are belong to us."
    redirect_to user_path(current_user)
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    flash[:danger] = "That's not a thing in the database"
    redirect_to user_path(current_user)
  end

  def current_user
    User.find session[:id] if session[:id]
  end
  helper_method :current_user  #makes available in view

end
