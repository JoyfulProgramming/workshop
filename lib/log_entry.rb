class LogEntry
  include Mongoid::Document

  field :message, type: String
  field :created_at, type: Time, default: -> { Time.now }
end
