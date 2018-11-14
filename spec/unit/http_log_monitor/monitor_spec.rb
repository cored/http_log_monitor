require "spec_helper"

RSpec.describe HttpLogMonitor::Monitor do
  subject(:monitor) do
    described_class.new(attributes)
  end

  let(:attributes) { {} }
  let(:log) do
    HttpLogMonitor::Log.new(
      host: "127.0.0.1",
      user: "james",
      date: DateTime.new(2018, 11, 8, 10, 00, 00, Rational(-5, 24)),
      section: "index.php",
      code: "200",
      bytes: 123
    )
  end
  let(:invalid_log) { HttpLogMonitor::Log.new(date: DateTime.new(2018, 11, 8, 11, 00, 00, Rational(-5, 24))) }

  describe "#add" do
    context "when the log is valid" do
      it "process logs" do
				expect(monitor.add(log).logs_count).to eql 1
			end
    end

    context "when the log is invalid" do
      it "does not include the invalid log to the queue" do
        expect(monitor.add(invalid_log).logs_count).to eql 0
      end
    end

    context "when an a log is getting hit in the alert period threshold" do
      let(:attributes) { {alerts_threshold: 2, threshold: 1} }
      let(:recovering_log) do
        HttpLogMonitor::Log.new(
          host: "127.0.0.1",
          user: "james",
          date: DateTime.new(2018, 11, 8, 11, 00, 00, Rational(-5, 24)),
          section: "/reports",
          code: "200",
          bytes: 123
    )
      end

      it "generates an alert" do
        Timecop.freeze DateTime.new(2018, 11, 8, 10, 02, 00, Rational(-5, 24)) do
          expect(
            monitor
            .add(log)
            .add(log)
            .add(log).alerts_stats
          ).to match(/High Traffic/)
        end
      end

      it "recovers from an alert"do
        Timecop.freeze DateTime.new(2018, 11, 8, 11, 00, 00,
                                    Rational(-5, 24)) do
          monitor_with_alerts = monitor.add(log).add(log).add(log)

          expect(monitor_with_alerts.alerts_stats).to match(/Recover/)
        end
      end
    end
  end
end
