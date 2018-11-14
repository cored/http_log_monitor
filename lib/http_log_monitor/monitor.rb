module HttpLogMonitor
  class Monitor < Dry::Struct
    extend Forwardable

    delegate [:size] => :logs

    attribute :logs, Types::Array.of(Log).default([])
    attribute :sections, Types::Hash.default(Hash.new(0))
    attribute :http_codes, Types::Hash.default(Hash.new(0))
    attribute :file_path, Types::String.default("")
    attribute :invalid_logs_count, Types::Integer.default(0)
    attribute :refresh, Types::Coercible::Integer.default(ENV.fetch("MONITOR_REFRESH_TIME", 10))
    attribute :threshold, Types::Coercible::Integer.default(ENV.fetch("MONITOR_THRESHOLD", 120))
    attribute :alerts_threshold, Types::Coercible::Integer.default(ENV.fetch("ALERTS_THRESHOLD", 500))
    attribute :alert, Alert.default(Alert.new)

    def process(log)
      new_logs = logs_within_threshold
      new_invalid_logs_count = invalid_logs_count
      new_sections = Hash.new(0)
      new_http_codes = Hash.new(0)

      if log.valid?
        new_logs += [log]
        new_http_codes = http_codes.merge(
          log.code => http_codes[log.code] + 1
        )

        new_sections = sections.merge(
          log.section => sections[log.section] + 1
        )
      else
        new_invalid_logs_count += 1
      end

      new(
        sections: new_sections,
        http_codes: new_http_codes,
        logs: new_logs,
        invalid_logs_count: new_invalid_logs_count,
        alert: alert.with(
          hits: amount_of_hits_after_2_minutes(log.section),
          threshold: alerts_threshold
        )
      )
    end

    def alerts_stats
      alert.to_s
    end

    def http_code_stats
      http_codes.map do |code, amount|
        [
          code,
          amount
        ].join(" - ")
      end
    end

    def total_bytes
      logs.map(&:bytes).sum
    end

    def total_hits
      size
    end

    def average_bytes
      return 0 if total_bytes.zero?
      total_bytes / total_hits
    end

    def most_hit_section
      ascending_sorted_sections.reverse.first
    end

    def less_hit_section
      ascending_sorted_sections.first
    end

    def ascending_sorted_sections
      @_sorted_sections ||= sections.sort
    end

    private

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

    def amount_of_hits_after_2_minutes(section)
      logs_within_threshold.select do |log|
        time_diff = Time.at((current_time_in_seconds - log.date.to_time).to_i.abs).strftime("%M:%S")
        time_diff.to_i == 2
      end.count
    end

    def current_time_in_seconds
      Time.now.to_time
    end
  end
end
