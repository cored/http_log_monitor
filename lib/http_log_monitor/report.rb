module HttpLogMonitor
  class Report
    def initialize(monitor:, refresh: 10)
      @monitor = monitor
      @refresh = refresh
    end

    def display
      Thread.new do
        refresh_after(refresh) do
          clear_screen
          to_s
        end
      end
    end

    def with(monitor)
      self.class.new(monitor: monitor)
    end

    def to_s
      puts "Total hits: %d" % monitor.total_hits
      puts "Hits - Threshold: %s Current: %d" % [monitor.threshold, monitor.total_hits]
      puts "Bytes - Total: %s Avg: %d" % [monitor.total_bytes, monitor.average_bytes]
      puts "Sections "
      puts "=================================================================="
      puts "Name - Total Hits: %s" % [monitor.sections.to_s]
      puts "=================================================================="
      puts "Alerts"
      puts "High Traffic: %d" % [monitor.total_alerts]
    end

    private

    attr_reader :monitor, :refresh

    def refresh_after(seconds)
      loop do
        before = Time.now
        yield
        interval = seconds - (Time.now - before)
        sleep(interval) if interval > 0
      end
    end

    def clear_screen
      system "clear" or system "cls"
    end
  end
end
