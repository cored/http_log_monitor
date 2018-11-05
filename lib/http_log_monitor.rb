require "dry-struct"
require "apachelogregex"
require "http_log_monitor/version"

require_relative "./http_log_monitor/types"
require_relative "./http_log_monitor/alerts"
require_relative "./http_log_monitor/log"
require_relative "./http_log_monitor/log_queue"
require_relative "./http_log_monitor/monitor"
require_relative "./http_log_monitor/report"

module HttpLogMonitor
  def self.call(options:)
    monitor = Monitor.for(options)
    report = Report.new(monitor: monitor)

    report.display

    ARGF.each_line do |line|
      log = Log.for(line)
      monitor = monitor.add(log)

      report = report.with(monitor)
    end
    report.to_s
  rescue Interrupt
    report.to_s
  end
end
