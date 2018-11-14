require "spec_helper"

RSpec.describe HttpLogMonitor::Alerts do
	subject(:alerts) { described_class.new }

	describe "#with" do
		context "when the hits is greater than the alert threshold" do
			specify do
				expect(
					alerts.with(hits: 1, threshold: 1).to_s
				).to match(/High Traffic/)
			end
		end

		context "when the hits are lower than the alert threshold" do
			specify do
				expect(
					alerts.with(hits: 1, threshold: 10).to_s
				).to match(/Recover/)
			end
		end
	end
end
