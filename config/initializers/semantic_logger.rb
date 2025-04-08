# config/initializers/semantic_logger.rb

require "semantic_logger"
require_relative "../../lib/flat_json_formatter"

SemanticLogger.add_appender(
  appender: :http,
  url: "https://#{ENV.fetch("DYNATRACE_APP_ID")}.live.dynatrace.com/api/v2/logs/ingest",
  formatter: FlatJsonFormatter.new,
  header: {
    "Content-Type" => "application/json",
    "Authorization" => "Api-Token #{ENV.fetch("DYNATRACE_API_TOKEN")}"
  }
)
