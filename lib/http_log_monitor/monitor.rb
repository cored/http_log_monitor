module HttpLogMonitor
  class Monitor < Dry::Struct
    attribute :log_counts, Types::Integer.default(0)
    attribute :sections, Types::Hash.default(Hash.new(0))
    attribute :hits_per_second, Types::Hash.default(Hash.new(0))
    attribute :http_codes, Types::Hash.default(Hash.new(0))
    attribute :file_path, Types::String.default("")
    attribute :total_bytes, Types::Integer.default(0)
    attribute :refresh, Types::Coercible::Integer.default(ENV.fetch("MONITOR_REFRESH_TIME", 10))
    attribute :threshold, Types::Coercible::Integer.default(ENV.fetch("MONITOR_THRESHOLD", 120))
    attribute :alerts_threshold, Types::Coercible::Integer.default(ENV.fetch("ALERTS_THRESHOLD", 10))
    attribute :alert, Alert.default(Alert.new)

    def process(log)
      new_log_counts = log_counts
      new_total_bytes = total_bytes
      new_sections = sections
      new_http_codes = http_codes
      new_hits_per_seconds = hits_per_second

      if log.valid?
        new_log_counts += 1
        new_total_bytes += log.bytes
        new_http_codes = http_codes.merge(
          log.code => http_codes[log.code] + 1
        )

        new_sections = sections.merge(
          log.section => sections[log.section] + 1
        )

        new_hits_per_seconds = hits_per_second.merge(
          log.date_in_seconds => hits_per_second[log.date_in_seconds] + 1
        )
      end

      new(
        log_counts: new_log_counts,
        hits_per_second: new_hits_per_seconds,
        sections: new_sections,
        total_bytes: new_total_bytes,
        http_codes: new_http_codes,
        alert: alert.with(
          hits: amount_of_hits_for_the_past_2_minutes,
          threshold: alerts_threshold,
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

    def total_hits
      log_counts
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

    def amount_of_hits_for_the_past_2_minutes
      hits_per_second.reduce(0) do |sum, kv|
        sum += kv[1] if kv[1] >= alerts_threshold
        sum
      end
    end
  end
end
