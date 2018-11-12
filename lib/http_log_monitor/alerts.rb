module HttpLogMonitor
  class Alerts < Dry::Struct
    class Alert < Dry::Struct
      attribute :hits, Types::Integer.default(0)
      attribute :section, Types::String.default("")
      attribute :date, Types::DateTime.default(DateTime.now)
    end

    attribute :alerts, Types::Array.of(Alert).default([])

    def with(section:, hits:, threshold:)
      if hits >= threshold
        new(alerts: alerts + [Alert.new(hits: hits, section: section)])
      else
        new(alerts: recover_for(section))
      end
    end

    def to_a
      alerts
    end

    def count
      alerts.size
    end

    def stats
      to_h.map do |section, alerts|
        [section, alerts.count, alerts.map(&:date)]
      end
    end

    private

    def to_h
      alerts.group_by(&:section)
    end

    def recover_for(section)
      alerts.reject do |alert|
        alert.section == section
      end
    end
  end
end
