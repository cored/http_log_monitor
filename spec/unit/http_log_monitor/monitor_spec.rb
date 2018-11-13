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

    context "when an a log is getting hit in the alert period threshold" do
      let(:attributes) { {alerts_threshold: 1} }

      it "generates an alert" do
        Timecop.freeze DateTime.new(2018, 11, 8, 10, 02, 00, Rational(-5, 24)) do
          expect(
            monitor
            .add(log)
            .add(log)
            .add(log).to_h[:alerts]
          ).to_not be_empty
        end
      end

      it "recovers from an alert"do
        Timecop.freeze DateTime.new(2018, 11, 8, 10, 02, 00,
                                    Rational(-5, 24)) do
          monitor_with_alerts = monitor.add(log).add(log).add(log)

          expect(
            monitor_with_alerts.to_h[:alerts]
          ).to_not be_empty

          expect(
            recover.to_h[:alerts]
          ).to be_empty
        end
      end
    end
  end

  describe "#to_s" do
    context "when the log is valid" do
      pending "includes the log into the queue" do
        Timecop.freeze DateTime.new(2018, 11, 8, 10, 02, 00,
                                    Rational(-5, 24)) do
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
