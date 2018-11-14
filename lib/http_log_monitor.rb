require "http_log_monitor/version"
require "dotenv"
require_relative "./http_log_monitor/types"

module HttpLogMonitor
  Dotenv.load!

  def self.call(options:)
    monitor = Monitor.new(options)
    report = Report.new(monitor: monitor)

    f = File.open(monitor.file_path, "r")

    Thread.new do
      report.render
    end

    loop do
      select([f])
      line = f.gets

      Thread.new do
        log = Log.for(line.to_s)
        monitor = monitor.add(log)
        report.with(monitor)
      end.join
    end
  rescue Errno::ENOENT
    puts "#{monitor.file_path} doesn't exist"
  rescue Interrupt
    report.to_s
  end
end
