module HttpLogMonitor
  class Alert < Dry::Struct
    def with(hits:, threshold:)
      if hits >= threshold
        new(hits: hits, threshold: threshold, high: true)
      else
        new(hits: hits, threshold: threshold)
      end
    end

    attribute :hits, Types::Integer.default(0)
    attribute :time, Types::Time.default(Time.now)
    attribute :high, Types::Bool.default(false)
    attribute :threshold, Types::Integer.default(10)

    def to_s
      if high
        "High Traffic at (#{formatted_time}) with hits: #{hits} - threshold: #{threshold}"
      else
        "No Alerts - Recover at (#{formatted_time})"
      end
    end

    private

    def formatted_time
      time.strftime("%H:%M:%S %p")
    end
  end
end
