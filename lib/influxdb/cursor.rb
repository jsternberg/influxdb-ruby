require "msgpack"

module InfluxDB
  class Cursor
    include Mixins::Enumerable

    def initialize(io)
      @io = io
      @unpacker = MessagePack::Unpacker.new(@io)
      @unpacker.register_type(0x5) { |data|
        d = data.bytes
        secs = d[0] << 56
        secs += d[1] << 48
        secs += d[2] << 40
        secs += d[3] << 32
        secs += d[4] << 24
        secs += d[5] << 16
        secs += d[6] << 8
        secs += d[7]

        nsecs = d[8] << 24
        nsecs += d[9] << 16
        nsecs += d[10] << 8
        nsecs += d[11]
        Time.at(secs, nsecs/1000.0)
      }
    end

    def next
      return if @io.eof?
      result = @unpacker.read
      if err = result["error"]
        raise ResultError.new(err)
      end
      ResultSet.new(result, @io, @unpacker)
    end

    def close
      @io.close
    end
  end

  class ResultSet
    include Mixins::Enumerable

    attr_reader :id, :messages

    def initialize(result, io, unpacker)
      @io = io
      @unpacker = unpacker
      @id = result["id"]
      if messages = result["messages"]
        @messages = messages.map {|m| Message.new(m)}
      else
        @messages = []
      end
      @remaining = unpacker.read
      @series = nil
      @done = false
    end

    def next
      return if done?
      if @remaining.zero?
        return if @io.eof?
        @remaining = @unpacker.read
        if @remaining.zero?
          @done = true
          return
        end
      end

      series = @unpacker.read
      @remaining -= 1
      if err = series["error"]
        raise ResultError.new(err)
      end
      Series.new(series, @io, @unpacker).tap {|s| @series = s}
    end

    def discard
      until done?
        @series.discard if @series
        self.next
      end
    end

    def done?
      @done
    end
  end

  class Message
    attr_reader :level, :text

    def initialize(message)
      @level = message["level"].to_sym
      @text = message["text"]
    end

    def to_s
      text
    end
  end

  class Series
    include Mixins::Enumerable

    attr_reader :name, :tags, :columns

    def initialize(series, io, unpacker)
      @name = series["name"]
      @tags = series["tags"].freeze
      @columns = series["columns"].freeze
      @io = io
      @unpacker = unpacker
      @remaining = unpacker.read
      @done = false
    end

    def next
      return if done?
      if @remaining.zero?
        return if @io.eof?
        @remaining = @unpacker.read
        return if @remaining.zero?
      end

      row = @unpacker.read
      @remaining -= 1
      if err = row["error"]
        raise ResultError.new(err)
      end
      row["values"]
    end

    def discard
      until done?
        until @remaining.zero?
          @unpacker.skip
          @remaining -= 1
        end
        @remaining = @unpacker.read
        @done = true if @remaining.zero?
      end
    end

    def done?
      @done
    end
  end
end
