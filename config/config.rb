require "pliny/config_helpers"

# Access all config keys like the following:
#
#     Config.database_url
#
# Each accessor corresponds directly to an ENV key, which has the same name
# except upcased, i.e. `DATABASE_URL`.
module Config
  extend Pliny::CastingConfigHelpers

  # Mandatory -- exception is raised for these variables when missing.
  mandatory :api_key_hmac_secret
  mandatory :database_url
  mandatory :heroku_api_key
  mandatory :mailgun_smtp_login
  mandatory :mailgun_smtp_password
  mandatory :mailgun_smtp_port,      int
  mandatory :mailgun_smtp_server

  # Optional -- value is returned or `nil` if it wasn't present.
  optional :console_banner
  optional :obscurity_api_header
  optional :versioning_app_name
  optional :versioning_default

  # Override -- value is returned or the set default
  override :db_pool,          5,     int
  override :force_ssl,        true,  bool
  override :port,             5000,  int
  override :puma_max_threads, 16,    int
  override :puma_min_threads, 1,     int
  override :puma_workers,     3,     int
  override :raise_errors,     false, bool
  override :timeout,          45,    int
  override :versioning,       false, bool

  override :root,             File.expand_path("../../", __FILE__)
  override :rack_env,         'development'
end
