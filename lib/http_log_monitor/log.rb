require "apachelogregex"

module HttpLogMonitor
  class Log < Dry::Struct
    ACCESS_LOG_PARSER_FORMAT = '%h %l %u %t \"%r\" %>s %b'

    def self.for(data)
      parser = ApacheLogRegex.new(ACCESS_LOG_PARSER_FORMAT)
      attrs = parser.parse!(data)
      new(
        host: attrs["%h"],
        user: attrs["%u"],
        date: DateTime.strptime(
          attrs["%t"].gsub(/\[|\]/, ""), format = '%e/%b/%Y:%H:%M:%S %z'
        ),
        section: attrs["%r"].split(/\s/)[1],
        code: attrs["%>s"],
        bytes: attrs["%b"]
      )
    rescue ApacheLogRegex::ParseError
      new(date: DateTime.new)
    end

    attribute :host, Types::String.default("")
    attribute :user, Types::String.default("")
    attribute :date, Types::DateTime
    attribute :section, Types::String.default("")
    attribute :code, Types::String.default("")
    attribute :bytes, Types::Coercible::Integer.default(0)

    def valid?
      !host.empty? && !user.empty? && !section.empty? && !code.empty?
    end

    def to_h
      {
        host: host,
        user: user,
        date: date.strftime("%Y-%m-%d"),
        code: code,
        section: section,
        bytes: bytes,
      }
    end
  end
end
