module HttpLogMonitor
  class Alert < Dry::Struct
    def self.for(hits:, threshold:)
      if hits >= threshold
        new(
          hits: hits,
          description: "High Traffic at #{Time.now.strftime("%H:%M:%S %p")}"
        )
      else
        new(
          hits: hits,
          description: "No Alerts - Recover at #{Time.now.strftime("%H:%M:%S %p")}"
        )
      end
    end

    attribute :hits, Types::Integer.default(0)
    attribute :description, Types::String.default("")

    def to_s
      description
    end
  end
end
