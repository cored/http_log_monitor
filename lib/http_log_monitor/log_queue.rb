module HttpLogMonitor
  class LogQueue < Dry::Struct
    attribute :logs, Types::Array.of(Log).default([])
    attribute :alerts_threshold, Types::Integer.default(500)
    attribute :alerts, Alerts.default(Alerts.new)
    attribute :sections, Types::Hash.default(Hash.new(0))

    def current_hits
      logs.size
    end

    def current_bytes
      logs.map(&:bytes).reduce(0, :+)
    end

    def push(log)
      new_logs = logs + [log]
      new_sections = sections.merge(
        log.section => sections[log.section] + 1
      )

      new(
        sections: new_sections,
        logs: new_logs,
        alerts: alerts.with(
          hits: sections[log.section],
          threshold: alerts_threshold
        )
      )
    end

    def total_alerts
      alerts.count
    end
  end
end
