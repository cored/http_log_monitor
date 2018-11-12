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
      date: DateTime.parse("2018-11-08"),
      section: "index.php",
      code: "200",
      bytes: 123
    )
  end
  let(:invalid_log) { HttpLogMonitor::Log.new(date: Date.today) }

  describe "#add" do
    context "when the log is valid" do
      it "includes the log into the queue" do
        Timecop.freeze DateTime.parse("2018-11-08") do
          expect(
            monitor.add(log).to_h
          ).to match({
            :alerts=> [],
            :alerts_threshold=>500,
            :file_path=>"",
            :invalid_logs_count=>0,
            :http_code_stats => { "200" => 1 },
            :logs=>[{
              :bytes=>123,
              :code=>"200",
              :date=> "2018-11-08",
              :host=>"127.0.0.1",
              :section=>"index.php",
              :user=>"james"
            }],
            :refresh=>10,
            :sections=>{"index.php"=>1},
            :threshold=>120
          })
        end
      end
    end

    context "when the log is invalid" do
      it "does not include the invalid log to the queue" do
        expect(
          monitor.add(invalid_log).to_h
        ).to match({
          :alerts=> [],
          :alerts_threshold=>500,
          :http_code_stats => {},
          :file_path=>"",
          :invalid_logs_count=>1,
          :logs=>[],
          :refresh=>10,
          :sections=>{},
          :threshold=>120
        })
      end
    end
  end

  describe "#to_s" do
    context "when the log is valid" do
      pending "includes the log into the queue" do
        Timecop.freeze DateTime.parse("2018-11-08") do
          expect(
            monitor.add(log).to_s
          ).to match()
        end
      end
    end

    context "when the log is invalid" do
      pending "does not include the invalid log to the queue" do
        expect(
          monitor.add(invalid_log).to_s
        ).to eql("")
      end
    end
  end
end
