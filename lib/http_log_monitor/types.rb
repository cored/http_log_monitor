require "dry-struct"

module HttpLogMonitor
  module Types
    include Dry::Types.module
  end
end

require_relative "./alerts"
require_relative "./log"
require_relative "./monitor"
require_relative "./report"
