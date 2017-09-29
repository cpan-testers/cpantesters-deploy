##################### Grafana Configuration Example #####################
#
# Everything has defaults so you only need to uncomment things you want to
# change

# possible values : production, development
; app_mode = production

# instance name, defaults to HOSTNAME environment variable value or hostname if HOSTNAME var is empty
; instance_name = ${HOSTNAME}

#################################### Paths ####################################
[paths]
# Path to where grafana can store temp files, sessions, and the sqlite3 db (if that is used)
#
;data = /var/lib/grafana
#
# Directory where grafana can store logs
#
;logs = /var/log/grafana
#
# Directory where grafana will automatically scan and look for plugins
#
;plugins = /var/lib/grafana/plugins

#
#################################### Server ####################################
[server]
# Protocol (http or https)
;protocol = http

# The ip address to bind to, empty will bind to all interfaces
;http_addr =

# The http port  to use
http_port = <%= $monitor_port %>

# The public facing domain name used to access grafana from a browser
domain = <%= $monitor_host %>

# Redirect to correct domain if host header does not match domain
# Prevents DNS rebinding attacks
;enforce_domain = false

# The full public facing url you use in browser, used for redirects and emails
# If you use reverse proxy and sub path specify full url (with sub path)
root_url = http://<%= $monitor_host %>/grafana

# Log web requests
;router_logging = false

# the path relative working path
;static_root_path = public

# enable gzip
;enable_gzip = false

# https certs & key file
;cert_file =
;cert_key =

#################################### Database ####################################
[database]
# You can configure the database connection by specifying type, host, name, user and password
# as seperate properties or as on string using the url propertie.

# Either "mysql", "postgres" or "sqlite3", it's your choice
;type = sqlite3
;host = 127.0.0.1:3306
;name = grafana
;user = root
# If the password contains # or ; you have to wrap it with trippel quotes. Ex """#password;"""
;password =

# Use either URL or the previous fields to configure the database
# Example: mysql://user:secret@host:port/database
;url =

# For "postgres" only, either "disable", "require" or "verify-full"
;ssl_mode = disable

# For "sqlite3" only, path relative to data_path setting
;path = grafana.db

#################################### Session ####################################
[session]
# Either "memory", "file", "redis", "mysql", "postgres", default is "file"
;provider = file

# Provider config options
# memory: not have any config yet
# file: session dir path, is relative to grafana data_path
# redis: config like redis server e.g. `addr=127.0.0.1:6379,pool_size=100,db=grafana`
# mysql: go-sql-driver/mysql dsn config string, e.g. `user:password@tcp(127.0.0.1:3306)/database_name`
# postgres: user=a password=b host=localhost port=5432 dbname=c sslmode=disable
;provider_config = sessions

# Session cookie name
;cookie_name = grafana_sess

# If you use session in https only, default is false
;cookie_secure = false

# Session life time, default is 86400
;session_life_time = 86400

#################################### Analytics ####################################
[analytics]
# Server reporting, sends usage counters to stats.grafana.org every 24 hours.
# No ip addresses are being tracked, only simple counters to track
# running instances, dashboard and error counts. It is very helpful to us.
# Change this option to false to disable reporting.
;reporting_enabled = true

# Set to false to disable all checks to https://grafana.net
# for new vesions (grafana itself and plugins), check is used
# in some UI views to notify that grafana or plugin update exists
# This option does not cause any auto updates, nor send any information
# only a GET request to http://grafana.net to get latest versions
;check_for_updates = true

# Google Analytics universal tracking code, only enabled if you specify an id here
;google_analytics_ua_id =

#################################### Security ####################################
[security]
# default admin user, created on startup
admin_user = <%= $monitor_user %>

# default admin password, can be changed before first start of grafana,  or in profile settings
admin_password = <%= $monitor_password %>

# used for signing
;secret_key = SW2YcwTIb9zpOOhoPsMm

# Auto-login remember days
;login_remember_days = 7
;cookie_username = grafana_user
;cookie_remember_name = grafana_remember

# disable gravatar profile images
;disable_gravatar = false

# data source proxy whitelist (ip_or_domain:port separated by spaces)
;data_source_proxy_whitelist =

[snapshots]
# snapshot sharing options
;external_enabled = true
;external_snapshot_url = https://snapshots-origin.raintank.io
;external_snapshot_name = Publish to snapshot.raintank.io

# remove expired snapshot
;snapshot_remove_expired = true

# remove snapshots after 90 days
;snapshot_TTL_days = 90

#################################### Users ####################################
[users]
# disable user signup / registration
allow_sign_up = false

# Allow non admin users to create organizations
allow_org_create = false

# Set to true to automatically assign new users to the default organization (id 1)
;auto_assign_org = true

# Default role new users will be automatically assigned (if disabled above is set to true)
;auto_assign_org_role = Viewer

# Background text for the user field on the login page
;login_hint = email or username

# Default UI theme ("dark" or "light")
;default_theme = dark

[auth]
# Set to true to disable (hide) the login form, useful if you use OAuth, defaults to false
disable_login_form = true

#################################### Anonymous Auth ##########################
[auth.anonymous]
# enable anonymous access
;enabled = false

# specify organization name that should be used for unauthenticated users
;org_name = Main Org.

# specify role for unauthenticated users
;org_role = Viewer

#################################### Github Auth ##########################
[auth.github]
enabled = true
allow_sign_up = true
client_id = 5a7b9dc9cd6d435bf04d
client_secret = 77d2d436322561bc83c8b4243074838d73622cb6
scopes = user:email,read:org
;auth_url = https://github.com/login/oauth/authorize
;token_url = https://github.com/login/oauth/access_token
;api_url = https://api.github.com/user
;team_ids =
allowed_organizations = cpan-testers metacpan

#################################### Google Auth ##########################
[auth.google]
;enabled = false
;allow_sign_up = true
;client_id = some_client_id
;client_secret = some_client_secret
;scopes = https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email
;auth_url = https://accounts.google.com/o/oauth2/auth
;token_url = https://accounts.google.com/o/oauth2/token
;api_url = https://www.googleapis.com/oauth2/v1/userinfo
;allowed_domains =

#################################### Generic OAuth ##########################
[auth.generic_oauth]
;enabled = false
;name = OAuth
;allow_sign_up = true
;client_id = some_id
;client_secret = some_secret
;scopes = user:email,read:org
;auth_url = https://foo.bar/login/oauth/authorize
;token_url = https://foo.bar/login/oauth/access_token
;api_url = https://foo.bar/user
;team_ids =
;allowed_organizations =

#################################### Grafana.net Auth ####################
[auth.grafananet]
;enabled = false
;allow_sign_up = true
;client_id = some_id
;client_secret = some_secret
;scopes = user:email
;allowed_organizations =

#################################### Auth Proxy ##########################
[auth.proxy]
;enabled = false
;header_name = X-WEBAUTH-USER
;header_property = username
;auto_sign_up = true
;ldap_sync_ttl = 60
;whitelist = 192.168.1.1, 192.168.2.1

#################################### Basic Auth ##########################
[auth.basic]
;enabled = true

#################################### Auth LDAP ##########################
[auth.ldap]
;enabled = false
;config_file = /etc/grafana/ldap.toml
;allow_sign_up = true

#################################### SMTP / Emailing ##########################
[smtp]
enabled = true
;host = localhost:25
;user =
;password =
;cert_file =
;key_file =
;skip_verify = false
from_address = admin@cpantesters.org

[emails]
;welcome_email_on_sign_up = false

#################################### Logging ##########################
[log]
# Either "console", "file", "syslog". Default is console and  file
# Use space to separate multiple modes, e.g. "console file"
;mode = console file

# Either "trace", "debug", "info", "warn", "error", "critical", default is "info"
;level = info

# optional settings to set different levels for specific loggers. Ex filters = sqlstore:debug
;filters =


# For "console" mode only
[log.console]
;level =

# log line format, valid options are text, console and json
;format = console

# For "file" mode only
[log.file]
;level =

# log line format, valid options are text, console and json
;format = text

# This enables automated log rotate(switch of following options), default is true
;log_rotate = true

# Max line number of single file, default is 1000000
;max_lines = 1000000

# Max size shift of single file, default is 28 means 1 << 28, 256MB
;max_size_shift = 28

# Segment log daily, default is true
;daily_rotate = true

# Expired days of log file(delete after max days), default is 7
;max_days = 7

[log.syslog]
;level =

# log line format, valid options are text, console and json
;format = text

# Syslog network type and address. This can be udp, tcp, or unix. If left blank, the default unix endpoints will be used.
;network =
;address =

# Syslog facility. user, daemon and local0 through local7 are valid.
;facility =

# Syslog tag. By default, the process' argv[0] is used.
;tag =


#################################### AMQP Event Publisher ##########################
[event_publisher]
;enabled = false
;rabbitmq_url = amqp://localhost/
;exchange = grafana_events

;#################################### Dashboard JSON files ##########################
[dashboards.json]
;enabled = false
;path = /var/lib/grafana/dashboards

#################################### Alerting ######################################
[alerting]
# Makes it possible to turn off alert rule execution.
;execute_alerts = true

#################################### Internal Grafana Metrics ##########################
# Metrics available at HTTP API Url /api/metrics
[metrics]
# Disable / Enable internal metrics
;enabled           = true

# Publish interval
;interval_seconds  = 10

# Send internal metrics to Graphite
[metrics.graphite]
# Enable by setting the address setting (ex localhost:2003)
;address =
;prefix = prod.grafana.%(instance_name)s.

#################################### Internal Grafana Metrics ##########################
# Url used to to import dashboards directly from Grafana.net
[grafana_net]
;url = https://grafana.net

#################################### External image storage ##########################
[external_image_storage]
# Used for uploading images to public servers so they can be included in slack/email messages.
# you can choose between (s3, webdav)
;provider =

[external_image_storage.s3]
;bucket_url =
;access_key =
;secret_key =

[external_image_storage.webdav]
;url =
;username =
;password =
