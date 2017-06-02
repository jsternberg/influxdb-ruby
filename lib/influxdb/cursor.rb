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
      @results = []
    end

    def next
      while @results.empty?
        return if @io.eof?
        results = @unpacker.read
        if err = results["error"]
          raise ResultError.new(err)
        end
        @results.concat(results["results"]) if results["results"]
      end

      result = @results.shift
      if err = result["error"]
        raise ResultError.new(err)
      end
      ResultSet.new(result).tap {|r| @cur = r}
    end

    def close
      @io.close
    end
  end

  class ResultSet
    include Mixins::Enumerable

    attr_reader :messages

    def initialize(result)
      @series = result["series"]
      if messages = result["messages"]
        @messages = messages.map {|m| Message.new(m)}
      else
        @messages = []
      end
      @partial = result["partial"] || false
    end

    def next
      while @series.empty?
        return if !@partial
        # Retrieve additional series by retrieving
      end
      Series.new(@series.shift)
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

    def initialize(series)
      @name = series["name"]
      @tags = series["tags"].freeze
      @columns = series["columns"].freeze
      @values = series["values"]
      @partial = series["partial"] || false
    end

    def next
      while @values.empty?
        return if !@partial
      end
      @values.shift
    end
  end
end
