require "spec_helper"

RSpec.describe HttpLogMonitor::Log do
  subject(:log) { described_class.for(data) }

  describe ".for" do
    context "when passing valid log data" do
      let(:data) do
        '127.0.0.1 - james [09/May/2018:16:00:39 +0000] "GET /report/index HTTP/1.0" 200 123'
      end

      specify do
        expect(log).to be_valid
      end

      specify do
        expect(log.to_h).to match({
          host: "127.0.0.1",
          user: "james",
          date: "2018-05-09",
          section: "/index",
          code: "200",
          bytes: 123,
        })
      end
    end

    context "when the log line doesn't have a section" do
      let(:data) do
        '127.0.0.1 - james [09/May/2018:16:00:39 +0000] "GET /report HTTP/1.0" 200 123'
      end

      specify do
        expect(log.to_h).to match({
          host: "127.0.0.1",
          user: "james",
          date: "2018-05-09",
          section: "/report",
          code: "200",
          bytes: 123,
        })
      end
    end

    context "when passing invalid log data" do
      let(:data) { "" }

      specify do
        expect(log).to_not be_valid
      end
    end
  end
end
