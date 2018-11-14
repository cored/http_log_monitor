# HttpLogMonitor

[![Maintainability](https://api.codeclimate.com/v1/badges/619b0bf79440ca90106d/maintainability)](https://codeclimate.com/github/cored/http_log_monitor/maintainability)

Monitor [common access](https://httpd.apache.org/docs/1.3/logs.html) logs to display useful statistics and report alerts.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'http_log_monitor'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install http_log_monitor

## Usage

```
$ bin/monitor --help

Usages: bin/monitor ACCESS_LOG_PATH [options]

Specific options:
		-a, --alerts-threshold <AMOUNT>  Hit alert threshold
		-t, --threshold <SECONDS>        Log retention threshold
		-h, --help                       Display help
```

## Report Stats

```
Monitor Info
--------------------------------------------------
Threshold: 1
Alert Threshold: 5
Refresh Time: 10
--------------------------------------------------
Log Stats
--------------------------------------------------
Filename: ./test_access.log
Total lines processed: 9
Total lines with errors: 0
---------------------------------------------------
Sections Stats
---------------------------------------------------
Most hits: ["/user", 6]
Less hits: ["/report", 3]
---------------------------------------------------
HTTP Codes Stats
----------------------------------------------------
200 - /report - /user - 7 - 503 - /user - 2
----------------------------------------------------
Alerts
-----------------------------------------------------
Total: 0
High Traffic Requests
```

## Configuration Settings

```
$ export MONITOR_REFRESH_TIME=10 # 10 by default
$ export MONITOR_ALERTS_THRESHOLD=500 # 500 by default
$ export MONITOR_THRESHOLD=120 # 120 by default
```

*Any of the environment variables will be overwritten by the options passed
through the command line*

## Features

- [x] Monitor a common log file and process statistics
- [x] Check for past processed logs to triggered alerts base on the total amount of
hits

## Known Bugs

- [ ] Fix none thread safe monitoring (At the moment there are just two threads
for processing logs and rendering this is not scalable)
- [ ] Remove more indirection between the monitor and the report

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cored/http_log_monitor. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the HttpLogMonitor project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/cored/http_log_monitor/blob/master/CODE_OF_CONDUCT.md).
