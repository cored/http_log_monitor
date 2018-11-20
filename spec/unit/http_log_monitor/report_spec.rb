require "spec_helper"

RSpec.describe HttpLogMonitor::Report do
  subject(:report) { described_class.new(monitor: monitor) }

  let(:monitor) do
    HttpLogMonitor::Monitor.new(
      hits_per_second: hits_per_second,
      alerts_threshold: alerts_threshold,
    )
  end

  describe "#to_s" do
    context "when the amount of hits per second go over the alerts threshold" do
      let(:alerts_threshold) { 1 }
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
      let(:hits_per_second) { HttpLogMonitor::Stats::HitsPerSecond.new.with(log) }

      specify do
        expect(report.to_s).to include("High Traffic")
      end
    end

    context "when the amount of hits per second go under the alerts threshold" do
      let(:alerts_threshold) { 10 }
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
      let(:hits_per_second) { HttpLogMonitor::Stats::HitsPerSecond.new.with(log) }

      specify do
        expect(report.to_s).to include("Recover")
      end
    end
  end
end
