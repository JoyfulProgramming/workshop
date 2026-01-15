# config/initializer/opentelemetry.rb

require "opentelemetry/sdk"
require "opentelemetry/exporter/otlp"
require "opentelemetry/instrumentation/all"

class BatchSpanProcessorWithDbStatementFlattening < OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor
  def on_start(span, context)
    # This is where we modify spans before they start.
    statement = span.attributes["db.statement"]
    if statement
      begin
        # Recursively convert nested JSON attributes to dotted format
        def flatten_json(obj, prefix = "")
          attributes = {}
          obj.each do |key, value|
            if value.is_a?(Hash)
              attributes.merge!(flatten_json(value, "#{prefix}#{key}."))
            else
              attributes["#{prefix}#{key}"] = value
            end
          end
          attributes
        end

        parsed_statement = JSON.parse(statement)
        flatten_json(parsed_statement).each do |key, value|
          span.set_attribute("db.statement.#{key}", value)
        end
      rescue JSON::ParserError
      end
    end
    super(span, context)
  end
end


OpenTelemetry::SDK.configure do |c|
  c.use_all(
    "OpenTelemetry::Instrumentation::ActiveJob" => {
      propagation_style: :link,
      span_naming: :job_class
    },
    "OpenTelemetry::Instrumentation::Mongo" => {
      db_statement: :include
    }
  )
  c.resource = OpenTelemetry::SDK::Resources::Resource.create(
    "service.commit_sha" => `git rev-parse HEAD`.strip
  )
  c.add_span_processor(
    BatchSpanProcessorWithDbStatementFlattening.new(
      OpenTelemetry::Exporter::OTLP::Exporter.new
    )
  )
end
