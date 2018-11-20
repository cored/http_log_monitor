require "filesize"

module HttpLogMonitor
  class Report
    def initialize(monitor:)
      @monitor = monitor
    end

    def with(monitor)
      @monitor = monitor

      self
    end

    def render
      refresh_after do
        clear_screen
        puts to_s
      end
    end

    def to_s
<<EOF
Monitor Info
--------------------------------------------------
Threshold: #{monitor.threshold}
Alert Threshold: #{monitor.alerts_threshold}
Refresh Time: #{monitor.refresh}
--------------------------------------------------
Log Stats
--------------------------------------------------
Filename: #{monitor.file_path}
Total lines processed: #{monitor.total_hits}
Total bytes: #{monitor.total_bytes}
Avg bytes: #{monitor.average_bytes}
---------------------------------------------------
Sections Stats
---------------------------------------------------
Most hits: #{monitor.most_hit_section}
Less hits: #{monitor.less_hit_section}
---------------------------------------------------
HTTP Codes Stats
----------------------------------------------------
Code - Hits
#{monitor.http_code_stats}
----------------------------------------------------
Alerts
-----------------------------------------------------
#{alert_or_recover}
EOF
    end

    private

    attr_reader :monitor

    def alert_or_recover
      Alert.for(hits: monitor.total_hits_per_second,
                threshold: monitor.alerts_threshold)
    end

    def clear_screen
      system("clear") or system("cls")
    end

    def refresh_after
      loop do
        before = Time.now
        yield
        interval = monitor.refresh - (Time.now - before)
        sleep(interval) if interval > 0
      end
    end
  end
end
