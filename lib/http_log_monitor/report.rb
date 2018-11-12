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
        puts monitor.to_s
      end
    end

    private

    attr_reader :monitor

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
