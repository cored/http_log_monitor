module HttpLogMonitor
  class Report
    def initialize(monitor:, refresh: 10)
      @monitor = monitor
      @refresh = refresh
    end

    def with(monitor)
      self.class.new(monitor: monitor, refresh: refresh)
    end

    def to_s
<<EOF
Monitor Info
--------------------------------------------------
Threshold: #{monitor.threshold}
Alert Threshold: #{monitor.alerts_threshold}
--------------------------------------------------
Log Stats
--------------------------------------------------
Filename: #{monitor.file_path}
Total lines processed: #{monitor.queue_size}
Total lines with errors: #{monitor.invalid_logs_count}
---------------------------------------------------
Sections Stats
---------------------------------------------------
Most hits: #{monitor.most_hit_section}
Less hits: #{monitor.less_hit_section}
---------------------------------------------------
HTTP Codes Stats
----------------------------------------------------
#{monitor.http_code_stats.join(" - ")}
----------------------------------------------------
Alerts
-----------------------------------------------------
Total: #{monitor.total_alerts}
High Traffic (Amount of hits for the last 2 minutes)
#{monitor.alerts_stats.join(" - ")}
EOF
    end

    def render
      clear_screen
      puts to_s
    end

    private

    attr_reader :monitor, :refresh

    def clear_screen
      system("clear") or system("cls")
    end

    def refresh_after
      loop do
        before = Time.now
        yield
        interval = refresh - (Time.now - before)
        sleep(interval) if interval > 0
      end
    end
  end
end
