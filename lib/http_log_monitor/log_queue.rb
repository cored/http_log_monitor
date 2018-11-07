module HttpLogMonitor
  class LogQueue < Dry::Struct
    extend Forwardable
    delegate [:size] => :logs

    alias :total_hits :size
    alias :queue_size :size

    attribute :logs, Types::Array.of(Log).default([])
    attribute :invalid_logs, Types::Array.of(Log).default([])
    attribute :threshold, Types::Coercible::Integer.default(ENV.fetch("MONITOR_THRESHOLD", 120))
    attribute :alerts_threshold, Types::Coercible::Integer.default(ENV.fetch("ALERTS_THRESHOLD", 500))
    attribute :alerts, Alerts.default(Alerts.new)
    attribute :sections, Types::Hash.default(Hash.new(0))

    def total_bytes
      logs.map(&:bytes).reduce(0, :+)
    end

    def average_bytes
      return 0 if total_bytes.zero?
      total_bytes / total_hits
    end

    def push(log)
      new_logs = logs_within_threshold
      new_invalid_logs = invalid_logs

      if log.valid?
        new_logs += [log]
      else
        new_invalid_logs += [log]
      end

      new_sections = sections.merge(
        log.section => sections[log.section] + 1
      )

      new(
        sections: new_sections,
        logs: new_logs,
        invalid_logs: new_invalid_logs,
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
      logs.group_by(&:code).sort
    end

    private

    def amount_of_hits_past_2_minutes_for(section)
      all_logs_for(section).select do |log|
        time_diff = Time.at((current_time_in_seconds - log.date.to_time).to_i.abs).strftime("%M:%S")
        time_diff.to_i == 2
      end.count
    end

    def all_logs_for(section)
      logs.select do |log|
        log.section == section
      end
    end

    def current_time_in_seconds
      Time.now.to_time
    end

    def logs_within_threshold
      oldest_log_idx  = nil

      logs.each_with_index do |log, idx|
        break if log.date.to_time >= threshold_seconds

        oldest_log_idx = idx
      end
      oldest_log_idx.nil? ? [] : logs[0..oldest_log_idx]
    end

    def threshold_seconds
      DateTime.now.to_time - (threshold / 86400)
    end
  end
end
