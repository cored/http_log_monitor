module HttpLogMonitor
  class Monitor < Dry::Struct
    attribute :total_hits, Stats::TotalHits.default(Stats::TotalHits.new)
    attribute :total_bytes, Stats::TotalBytes.default(Stats::TotalBytes.new)
    attribute :average_bytes, Stats::AverageBytes.default(
      Stats::AverageBytes.new
    )
    attribute :sections, Stats::Sections.default(Stats::Sections.new)
    attribute :http_codes, Stats::HttpCodes.default(Stats::HttpCodes.new)
    attribute :hits_per_second, Stats::HitsPerSecond.default(
      Stats::HitsPerSecond.new
    )
    attribute :file_path, Types::String.default("")
    attribute :refresh, Types::Coercible::Integer.default(ENV.fetch("MONITOR_REFRESH_TIME", 10))
    attribute :threshold, Types::Coercible::Integer.default(ENV.fetch("MONITOR_THRESHOLD", 120))
    attribute :alerts_threshold, Types::Coercible::Integer.default(ENV.fetch("ALERTS_THRESHOLD", 10))

    def process(log)
      new(
        total_hits: total_hits.with(log),
        total_bytes: total_bytes.with(log),
        average_bytes: average_bytes.with(total_bytes, total_hits),
        sections: sections.with(log),
        http_codes: http_codes.with(log),
        hits_per_second: hits_per_second.with(log) ,
      )
    end

    def total_hits_per_second
      hits_per_second.total
    end

    def http_code_stats
      http_codes.to_s
    end

    def most_hit_section
      sections.most_hit
    end

    def less_hit_section
      sections.less_hit
    end
  end
end
