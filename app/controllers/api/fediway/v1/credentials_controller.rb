# frozen_string_literal: true

# FEDIWAY: cookie-based first-party login. POST {email, password}, server creates
# a Devise session via sign_in, response sets the standard `_mastodon_session`
# cookie. Same trust model as github.com / slack.com / stripe.com web logins.
# Mirrors the user-state checks Mastodon's own Auth::SessionsController applies.
class Api::Fediway::V1::CredentialsController < Api::BaseController
  skip_forgery_protection only: :create
  skip_before_action :require_authenticated_user!, only: :create

  def create
    user = User.find_for_authentication(email: params[:email])

    return render_error(:unauthorized, 'invalid_credentials') unless user&.valid_password?(params[:password])
    return render_error(:forbidden, 'two_factor_required') if user.otp_required_for_login?
    return render_error(:forbidden, 'unconfirmed') unless user.confirmed?
    return render_error(:forbidden, 'unapproved') unless user.approved?
    return render_error(:forbidden, 'disabled') unless user.functional?

    sign_in user
    render json: { ok: true }
  end

  private

  def render_error(status, code)
    render json: { error: code }, status: status
  end
end
