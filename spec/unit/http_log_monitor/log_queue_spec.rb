require "spec_helper"

RSpec.describe HttpLogMonitor::LogQueue do
  subject(:log_queues) { described_class.new }

  let(:log) do
    HttpLogMonitor::Log.new(
      host: "127.0.0.1",
      user: "james",
      date: "2018-05-09",
      section: "index.php",
      code: "200",
      bytes: 123
    )
  end

  describe "#current_hits" do
    context "when there are no logs in the queue" do
      specify do
        expect(log_queues.current_hits).to eql 0
      end
    end

    context "when there are logs in the queue" do
      specify do
        expect(log_queues.push(log).current_hits).to eql 1
      end
    end
  end

  describe "#current_bytes" do
    context "when there are no logs in the queue" do
      specify do
        expect(log_queues.current_bytes).to eql 0
      end
    end

    context "when there are logs in the queue" do
      specify do
        expect(log_queues.push(log).current_bytes).to eql 123
      end
    end
  end

  describe "#average_bytes" do
    context "when there are no logs in the queue" do
      specify do
        expect(log_queues.average_bytes).to eql 0
      end
    end

    context "when there are logs in the queue" do
      specify do
        expect(log_queues.push(log).average_bytes).to eql 123
      end
    end
  end
end
