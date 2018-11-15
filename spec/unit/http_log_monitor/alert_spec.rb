require "spec_helper"

RSpec.describe HttpLogMonitor::Alert do
  subject(:alert) { described_class.new }

  describe "#with" do
    context "when the amount of hits by pass the alerts threshold" do
      it "returns a high traffic alert" do
        expect(
          alert.with(hits: 1, threshold: 1).status
        ).to eql "High Traffic"
      end
    end

    context "when the amount of hits is less than the alerts threshold" do
      it "returns no alerts" do
        expect(
          alert.with(hits: 1, threshold: 10).status
        ).to eql "No Alerts - Recover"
      end
    end
  end
end
