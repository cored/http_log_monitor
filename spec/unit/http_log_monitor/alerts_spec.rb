require "spec_helper"

RSpec.describe HttpLogMonitor::Alerts do
  subject(:alerts) { described_class.new }

  describe "#with" do
    context "when the section hits is greater than the alert threshold" do
      specify do
        expect(alerts.with(section: "user",
                           hits: 1, threshold: 1).count).to eql 1
      end

      specify do
        Timecop.freeze DateTime.parse("2018-11-07 1:00") do
          expect(
            alerts
            .with(section: "user", hits: 1, threshold: 1)
            .to_a
            .map(&:date)
          ).to match_array [DateTime.parse("2018-11-07 1:00")]
        end
      end
    end

    context "when the section hits is less than the alert threshold" do
      specify do
        expect(alerts.with(section: "",
                           hits: 1, threshold: 5).count).to eql 0
      end
    end
  end
end
