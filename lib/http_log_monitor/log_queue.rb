module HttpLogMonitor
  class LogQueue < Dry::Struct
    attribute :logs, Types::Array.of(Log).default([])
    attribute :threshold, Types::Coercible::Integer.default(120)
    attribute :alerts_threshold, Types::Coercible::Integer.default(500)
    attribute :alerts, Alerts.default(Alerts.new)
    attribute :sections, Types::Hash.default(Hash.new(0))

    def current_hits
      valid_logs.size
    end

    def size
      valid_logs.size
    end

    def current_bytes
      valid_logs.map(&:bytes).reduce(0, :+)
    end

    def average_bytes
      return 0 if current_bytes.zero?
      current_bytes / current_hits
    end

    def push(log)
      new_logs = logs + [log]

      new_sections = sections.merge(
        log.section => sections[log.section] + 1
      )

      new(
        sections: new_sections,
        logs: new_logs,
        alerts: alerts.with(
          section: log.section,
          hits: amount_of_hits_past_2_minutes_for(log.section),
          threshold: alerts_threshold
        )
      )
    end

    def total_alerts
      alerts.count
    end

    def average_alerts
      return 0 if total_alerts.zero?
      current_hits / total_alerts
    end

    def invalid_logs_count
      invalid_logs.count
    end

    def most_hit_section
      sections.sort.reverse.first
    end

    def less_hit_section
      sections.sort.first
    end

    def most_processed_http_codes
      valid_logs.group_by(&:code).sort
    end

    private

    def amount_of_hits_past_2_minutes_for(section)
      all_logs_for(section).select do |log|
        time_diff = Time.at((current_time_in_seconds - log.date.to_time).to_i.abs).strftime("%M:%S")
        time_diff.to_i == 2
      end.count
    end

    def valid_logs
      logs.select(&:valid?)
    end

    def invalid_logs
      logs.reject(&:valid?)
    end

    def all_logs_for(section)
      valid_logs.select do |log|
        log.section == section
      end
    end

    def current_time_in_seconds
      Time.now.to_time
    end
  end
end
