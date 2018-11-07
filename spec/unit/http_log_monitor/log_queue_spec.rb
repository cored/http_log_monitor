require "timecop"
require "spec_helper"

RSpec.describe HttpLogMonitor::LogQueue do
  subject(:log_queue) do
    described_class.new(threshold: threshold, alerts_threshold: 1)
  end

  let(:log) do
    HttpLogMonitor::Log.new(
      host: "127.0.0.1",
      user: "james",
      date: DateTime.parse("2018-11-06 10:00+5:00"),
      section: "index.php",
      code: "200",
      bytes: 123
    )
  end

  let(:invalid_log) do
    HttpLogMonitor::Log.new(date: DateTime.new(2018, 11, 06, 10, 00))
  end
  let(:threshold) { 10 }

  describe "#push" do
    context "when passing a section with hits for the past 2 minutes" do
      it "creates an alert" do
        Timecop.freeze DateTime.new(2018, 11, 06, 10, 02) do
          expect(
            log_queue
            .push(log)
            .push(log).total_alerts
          ).to eql 1
        end
      end
    end

    context "when some logs are past the threshold" do
      let(:threshold) { 2 }
      let(:beyond_log) do
        HttpLogMonitor::Log.new(
          host: "127.0.0.1",
          user: "paula",
          date: DateTime.parse("2018-11-06 11:00+5:00"),
          section: "index.php",
          code: "200",
          bytes: 123
        )
      end

      it "omits those logs" do
        Timecop.freeze DateTime.parse("2018-11-06 10:00+5:00") do
          expect(
            log_queue.push(log).push(beyond_log).total_hits
          ).to eql 1
        end
      end
    end
  end

  describe "#total_hits" do
    context "when there are no logs in the queue" do
      specify do
        expect(log_queue.total_hits).to eql 0
      end
    end

    context "when there are logs in the queue" do
      let(:threshold) { 1 }

      specify do
        Timecop.freeze DateTime.new(2018, 11, 06, 10, 02) do
          expect(
            log_queue
            .push(log)
            .push(log)
            .push(invalid_log)
            .total_hits
          ).to eql 2
        end
      end
    end
  end

  describe "#total_bytes" do
    context "when there are no logs in the queue" do
      specify do
        expect(log_queue.total_bytes).to eql 0
      end
    end

    context "when there are logs in the queue" do
      specify do
        expect(log_queue.push(log).total_bytes).to eql 123
      end
    end
  end

  describe "#average_bytes" do
    context "when there are no logs in the queue" do
      specify do
        expect(log_queue.average_bytes).to eql 0
      end
    end

    context "when there are logs in the queue" do
      specify do
        expect(log_queue.push(log).average_bytes).to eql 123
      end
    end
  end
end
