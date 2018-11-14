module HttpLogMonitor
  class Alert < Dry::Struct
    def with(hits:, threshold:)
      if hits >= threshold
        new(hits: hits, status: "High Traffic", threshold: threshold)
      else
        new(hits: hits, status: "No Alerts", threshold: threshold)
      end
    end

    attribute :hits, Types::Integer.default(0)
    attribute :time, Types::Time.default(Time.now)
    attribute :status, Types::String.default("No Alerts")
    attribute :threshold, Types::Integer.default(0)

    def to_s
      "#{status} at #{time} with #{hits} hits over the threshold"
    end
  end
end
