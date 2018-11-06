module HttpLogMonitor
  class Alerts < Dry::Struct
    class Alert < Dry::Struct
      attribute :hits, Types::Integer.default(0)
      attribute :section, Types::String.default("")
    end

    attribute :alerts, Types::Array.of(Alert).default([])

    def with(section:, hits:, threshold:)
      if hits >= threshold
        new(alerts: alerts + [Alert.new(hits: hits, section: section)])
      else
        new(alerts: [])
      end
    end

    def count
      alerts.size
    end

    def to_h
      alerts.group_by(&:section)
    end

    private

    def recover_for(section)
      alerts.reject do |alert|
        alert.section == section
      end
    end
  end
end
