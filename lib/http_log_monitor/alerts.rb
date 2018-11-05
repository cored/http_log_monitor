module HttpLogMonitor
  class Alerts < Dry::Struct
    class Alert < Dry::Struct
      attribute :hits, Types::Integer.default(0)
    end

    attribute :alerts, Types::Array.of(Alert).default([])

    def with(hits:, threshold:)
      if hits >= threshold
        new(alerts: alerts + [Alert.new(hits: hits)])
      else
        self
      end
    end

    def count
      alerts.size
    end
  end
end
