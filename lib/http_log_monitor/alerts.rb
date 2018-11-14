module HttpLogMonitor
  class Alerts < Dry::Struct
    class Alert < Dry::Struct
      attribute :hits, Types::Integer.default(0)
      attribute :time, Types::Time.default(Time.now)
      attribute :status, Types::String.default("")

      def to_s
        "#{status} at #{time} with #{hits} hits over the threshold"
      end
    end

    attribute :alert, Alert

    def with(hits:, threshold:)
      if hits >= threshold
        new(alert: Alert.new(hits: hits, status: "High Traffic"))
      else
        new(alert: Alert.new(hits: hits, status: "Recover"))
      end
    end

    def to_s
      alert.to_s
    end
  end
end
