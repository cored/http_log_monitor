require "http_log_monitor/version"
require "dotenv"
require_relative "./http_log_monitor/types"

module HttpLogMonitor
  Dotenv.load!

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
      sleep(monitor.refresh)
    end
  rescue Errno::ENOENT
    puts "#{monitor.file_path} doesn't exist"
  rescue Interrupt
    report.to_s
  end
end
