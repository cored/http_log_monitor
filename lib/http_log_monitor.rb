require "http_log_monitor/version"
require "dotenv"
require_relative "./http_log_monitor/types"

module HttpLogMonitor
  Dotenv.load

  def self.call(options:)
    monitor = Monitor.new(options)
    report = Report.new(monitor: monitor)

    file = build_file_for(monitor.file_path)
    process_report_with(report)
    process_file_content(file, monitor, report)
  rescue Interrupt
    report.to_s
  end

  def self.build_file_for(file_path)
    File.open(file_path, "r")
  rescue Errno::ENOENT
    puts "#{file_path} doesn't exist"
  end

  def self.process_report_with(report)
    Thread.new do
      report.render
    end
  end

  def self.process_file_content(file, monitor, report)
    loop do
      select([file])
      line = file.gets
      Thread.new do
        log = Log.for(line.to_s)
        monitor = monitor.process(log)
        report.with(monitor)
      end
    end
  end
end
