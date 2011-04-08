# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_planner_session',
  :secret      => 'e56f42ddd3aa354df27fd32034bcd2b52fc3c065415aad624ccbdd06ceddec5b7f3e1a5499ffd9af99d2c034ff47631861846c7dfb961d7fb70fd694fca8de53'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
