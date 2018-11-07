module HttpLogMonitor
  class Monitor < Dry::Struct
    extend Forwardable

    delegate [
      :total_hits,
      :total_bytes,
      :total_alerts,
      :threshold,
      :sections,
      :less_hit_section,
      :most_hit_section,
      :queue_size,
      :invalid_logs_count,
      :average_bytes,
      :alerts_threshold,
      :average_alerts,
    ] => :log_queue

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

    def alerts_stats
      log_queue.alerts.to_h.map do |section, alerts|
        [section, alerts.count, alerts.map(&:date)]
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
  end
end
