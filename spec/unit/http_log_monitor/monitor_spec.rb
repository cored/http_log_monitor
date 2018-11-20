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

  describe "#total_hits_per_second" do
    it "quantifies the total amount of hits per second" do
      expect(monitor.process(log).total_hits_per_second).to eql 1
    end
  end

  describe "#http_code_stats" do
    specify do
      expect(monitor.process(log).http_code_stats).to eql "200 - 1"
    end
  end

  describe "#most_hit_section" do
    specify do
      expect(monitor.process(log).most_hit_section).to eql ["index.php", 1]
    end
  end

  describe "#less_hit_section" do
    specify do
      expect(monitor.process(log).less_hit_section).to eql ["index.php", 1]
    end
  end

  describe "#average_bytes" do
    specify do
      expect(monitor.process(log).average_bytes.to_s).to eql "0.00 B"
    end
  end

  describe "#total_hits" do
    specify do
      expect(monitor.process(log).total_hits.to_s).to eql "1"
    end
  end

  describe "#total_bytes" do
    specify do
      expect(monitor.process(log).total_bytes.to_s).to eql "123.00 B"
    end
  end
end
