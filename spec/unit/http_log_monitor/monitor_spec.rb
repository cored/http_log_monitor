require "spec_helper"

RSpec.describe HttpLogMonitor::Monitor do
  subject(:monitor) do
    described_class.for(attributes)
  end

  let(:attributes) { {} }
  let(:valid_log) do
    HttpLogMonitor::Log.new(
      host: "127.0.0.1",
      user: "james",
      date: "2018-05-09",
      section: "index.php",
      code: "200",
      bytes: 123
    )
  end
  let(:invalid_log) { HttpLogMonitor::Log.new(date: Date.today) }

  describe "#sections" do
    context "when passing an invalid log" do
      specify do
        expect(monitor.add(invalid_log).sections).to be_empty
      end
    end

    context "when passing a valid log" do
      specify do
        expect(monitor.add(valid_log).sections).to_not be_empty
      end
    end
  end

  describe "#total_hits" do
    context "when passing an invalid log" do
      specify do
        expect(monitor.add(invalid_log).total_hits).to eql 0
      end
    end

    context "when passing a valid log" do
      specify do
        expect(monitor.add(valid_log).total_hits).to eql 1
      end
    end
  end

  describe "#total_bytes" do
    context "when passing an invalid log" do
      specify do
        expect(monitor.add(invalid_log).total_bytes).to eql 0
      end
    end

    context "when passing a valid log" do
      specify do
        expect(monitor.add(valid_log).total_bytes).to eql 123
      end
    end
  end

  describe "#total_hits" do
    context "when passing an invalid log" do
      specify do
        expect(monitor.add(invalid_log).total_hits).to eql 0
      end
    end

    context "when passing a valid log" do
      specify do
        expect(monitor.add(valid_log).total_hits).to eql 1
      end
    end
  end
end
