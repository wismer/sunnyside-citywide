Sun::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.sequel.schema_format = :sql

  # Whether to dump the schema after successful migrations.
  # Defaults to false in production and test, true otherwise.
  config.sequel.schema_dump = true

  # These override corresponding settings from the database config.
  config.sequel.max_connections = 16
  config.sequel.search_path = %w(mine public)

  # Configure whether database's rake tasks will be loaded or not
  # Defaults to true
  config.sequel.load_database_tasks = false
end
