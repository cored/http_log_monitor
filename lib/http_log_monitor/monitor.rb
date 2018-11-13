module HttpLogMonitor
  class Monitor < Dry::Struct
    attribute :logs, Types::Array.of(Log).default([])
    attribute :sections, Types::Hash.default(Hash.new(0))
    attribute :http_codes, Types::Hash.default(Hash.new(0))
    attribute :file_path, Types::String.default("")
    attribute :invalid_logs_count, Types::Integer.default(0)
    attribute :refresh, Types::Coercible::Integer.default(ENV.fetch("MONITOR_REFRESH_TIME", 10))
    attribute :threshold, Types::Coercible::Integer.default(ENV.fetch("MONITOR_THRESHOLD", 120))
    attribute :alerts_threshold, Types::Coercible::Integer.default(ENV.fetch("ALERTS_THRESHOLD", 500))
    attribute :alerts, Alerts.default(Alerts.new)

    def to_s
<<EOF
Monitor Info
--------------------------------------------------
Threshold: #{threshold}
Alert Threshold: #{alerts_threshold}
Refresh Time: #{refresh}
--------------------------------------------------
Log Stats
--------------------------------------------------
Filename: #{file_path}
Total lines processed: #{logs_count}
Total lines with errors: #{invalid_logs_count}
---------------------------------------------------
Sections Stats
---------------------------------------------------
Most hits: #{most_hit_section}
Less hits: #{less_hit_section}
---------------------------------------------------
HTTP Codes Stats
----------------------------------------------------
Code - Hits
#{http_code_stats.join("\n")}
----------------------------------------------------
Alerts
-----------------------------------------------------
Total: #{total_alerts}
High Traffic Requests
#{alerts_stats.join(" - ")}
EOF
    end

    def add(log)
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
        alerts: alerts.with(
          section: log.section,
          hits: amount_of_hits_past_2_minutes_for(log.section),
          threshold: alerts_threshold
        )
      )
    end

    def to_h
      {
        alerts: alerts_stats,
        alerts_threshold: alerts_threshold,
        sections: sections,
        threshold: threshold,
        refresh: refresh,
        file_path: file_path,
        invalid_logs_count: invalid_logs_count,
        logs: logs.map(&:to_h),
        http_code_stats: http_codes,
      }
    end

    private

    def logs_count
      logs.size
    end

    def alerts_stats
      alerts.stats
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
      logs.map(&:bytes).reduce(0, :+)
    end

    def total_hits
      logs.size
    end

    def total_alerts
      alerts.count
    end

    def average_bytes
      return 0 if total_bytes.zero?
      total_bytes / total_hits
    end

    def average_alerts
      return 0 if total_alerts.zero?
      current_hits / total_alerts
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
  end
end
