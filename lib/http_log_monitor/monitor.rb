module HttpLogMonitor
  class Monitor < Dry::Struct
    def self.for(attributes)
      new(
        attributes.merge(
          log_queue: LogQueue.new(
            alerts_threshold: attributes.fetch(:alerts_threshold, 500),
            threshold: attributes.fetch(:threshold, 120)
          )
        )
      )
    end

    attribute :log_queue, LogQueue
    attribute :file_path, Types::String.default("")

    def add(log)
      new(log_queue: log_queue.push(log))
    end

    def threshold
      log_queue.threshold
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

    def queue_size
      log_queue.size
    end

    def section_most_hits
      log_queue.most_hit_section
    end

    def section_with_less_hits
      log_queue.less_hit_section
    end

    def invalid_logs_count
      log_queue.invalid_logs_count
    end

    def alerts_stats
      log_queue.alerts.to_h.map do |section, alerts|
        [section, alerts.count]
      end
    end

    def http_code_stats
      log_queue.most_processed_http_codes.map do |code, stats|
        [
          code,
          stats.map(&:section).uniq,
          stats.count,
        ]
      end
    end

    def average_alerts
      log_queue.average_alerts
    end

    def threshold
      log_queue.threshold
    end

    def alert_threshold
      log_queue.alerts_threshold
    end
  end
end
