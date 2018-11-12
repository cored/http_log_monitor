module HttpLogMonitor
  class Report
    def initialize(monitor:)
      @monitor = monitor
    end

    def with(monitor)
      self.class.new(monitor: monitor)
    end

    def render
      clear_screen
      puts monitor.to_s
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
