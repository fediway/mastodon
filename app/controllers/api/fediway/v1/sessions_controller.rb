# frozen_string_literal: true

# FEDIWAY: SSO bridge — exchange a Doorkeeper bearer token for a Devise session cookie
class Api::Fediway::V1::SessionsController < Api::BaseController
  skip_forgery_protection only: :bridge
  before_action -> { doorkeeper_authorize! }
  before_action :require_user!

  def bridge
    sign_in current_user
    render_empty
  end
end
