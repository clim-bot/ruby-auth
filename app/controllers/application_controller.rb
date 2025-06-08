class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  # Enable CSRF protection for all actions except those that allow unauthenticated access.
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private
  # This method is called when a record is not found.
  def not_found
    render file: Rails.root.join("public/404.html"), status: :not_found, layout: false
  end
end
