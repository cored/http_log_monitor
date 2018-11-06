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

    f = File.open(monitor.file_path, "r")

    loop do
      select([f])
      line = f.gets

      log = Log.for(line.to_s)
      monitor = monitor.add(log)

      report =  report.with(monitor)
      report.render
      sleep(2)
    end
  rescue Interrupt
    report.to_s
  end
end
