module HttpLogMonitor
  module Stats
    class TotalHits < Dry::Struct
      attribute :amount, Types::Integer.default(0)

      def with(log)
        if log.valid?
          new(amount: amount + 1)
        else
          self
        end
      end

      def to_i
        amount
      end

      def to_s
        amount.to_s
      end
    end

    class TotalBytes < Dry::Struct
      attribute :amount, Types::Integer.default(0)

      def with(log)
        if log.valid?
          new(amount: amount + log.bytes)
        else
          self
        end
      end

      def /(other)
        return 0 if amount.zero?
        amount / other.amount
      end

      def to_i
        amount
      end

      def to_s
        Filesize.from(amount.to_s).pretty
      end
    end

    class AverageBytes < Dry::Struct
      attribute :average, Types::Integer.default(0)

      def with(total_bytes, total_hits)
        new(average: total_bytes / total_hits)
      end

      def to_s
        Filesize.from(average.to_s).pretty
      end
    end

    class Sections < Dry::Struct
      attribute :section, Types::Hash.default(Hash.new(0))

      def with(log)
        if log.valid?
          new(
            section: section.merge(log.section => section[log.section] + 1)
          )
        else
          self
        end
      end

      def most_hit
        ascending_sorted_sections.reverse.first
      end

      def less_hit
        ascending_sorted_sections.first
      end

      private

      def ascending_sorted_sections
        @_sorted_sections ||= section.sort
      end
    end

    class HttpCodes < Dry::Struct
      def with(log)
        if log.valid?
          new(stats: stats.merge(log.code => stats[log.code] + 1))
        else
          self
        end
      end

      attribute :stats, Types::Hash.default(Hash.new(0))

      def to_s
        stats.map do |code, amount|
          [
            code,
            amount
          ].join(" - ")
        end.join("\n")
      end
    end

    class HitsPerSecond < Dry::Struct
      attribute :stats, Types::Hash.default(Hash.new(0))

      def with(log)
        if log.valid?
          new(
            stats: stats.merge(log.date_in_seconds => stats[log.date_in_seconds] + 1)
          )
        else
          self
        end
      end

      def total
        stats.values.reduce(0, :+)
      end
    end
  end
end
