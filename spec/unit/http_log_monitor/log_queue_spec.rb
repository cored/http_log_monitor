require "spec_helper"

RSpec.describe HttpLogMonitor::LogQueue do
  subject(:log_queues) { described_class.new }

  let(:log) { HttpLogMonitor::Log.new(date: Date.today, bytes: 123) }

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
