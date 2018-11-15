module HttpLogMonitor
  class Alert < Dry::Struct
    def with(hits:, threshold:)
      if hits >= threshold
        new(hits: hits, status: "High Traffic", threshold: threshold)
      else
        new(hits: hits, status: "No Alerts - Recover", threshold: threshold)
      end
    end

    attribute :hits, Types::Integer.default(0)
    attribute :time, Types::Time.default(Time.now)
    attribute :status, Types::String.default("No Alerts - Recover")
    attribute :threshold, Types::Integer.default(10)

    def to_s
      "#{status} at (#{time.strftime("%H:%M:%S %p")}) with hits: #{hits} - threshold: #{threshold}"
    end
  end
end
