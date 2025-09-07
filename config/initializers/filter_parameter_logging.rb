# Be sure to restart your server when you modify this file.

# Configure parameters to be partially matched (e.g. passw matches password) and filtered from the log file.
# Use this to limit dissemination of sensitive information.
# See the ActiveSupport::ParameterFilter documentation for supported notations and behaviors.
Rails.application.config.filter_parameters += [
  :passw, :email, :crypt, :salt, :certificate, :otp, :ssn,
  /token/i,   # access_token, refresh_token, csrf_token などまとめて
  /secret/i,  # api_secret など
  /key/i      # api_key, secret_key など
]
