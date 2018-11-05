require "spec_helper"

RSpec.describe HttpLogMonitor::Alerts do
  subject(:alerts) { described_class.new }

  describe "#with" do
    context "when the section hits is greater than the alert threshold" do
      specify do
        expect(alerts.with(hits: 1, threshold: 1).count).to eql 1
      end
    end

    context "when the section hits is less than the alert threshold" do
      specify do
        expect(alerts.with(hits: 1, threshold: 5).count).to eql 0
      end
    end
  end
end
