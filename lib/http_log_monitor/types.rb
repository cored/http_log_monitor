require "dry-struct"

module HttpLogMonitor
  module Types
    include Dry::Types.module
  end
end

require_relative "./alert"
require_relative "./log"
require_relative "./stats"
require_relative "./monitor"
require_relative "./report"
