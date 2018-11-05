module HttpLogMonitor
  class Monitor < Dry::Struct
    def self.for(attributes)
      new(
        attributes.merge(
          log_queue: LogQueue.new(
            alerts_threshold: attributes[:alerts_threshold]
          )
        )
      )
    end

    attribute :alerts_threshold, Types::Integer.default(500)
    attribute :threshold, Types::Integer.default(120)
    attribute :log_queue, LogQueue

    def add(log)
      if log.valid?
        new(log_queue: log_queue.push(log))
      else
        self
      end
    end

    def total_alerts
      log_queue.total_alerts
    end

    def sections
      log_queue.sections
    end

    def total_hits
      log_queue.current_hits
    end

    def total_bytes
      log_queue.current_bytes
    end

    def average_bytes
      log_queue.average_bytes
    end
  end
end
