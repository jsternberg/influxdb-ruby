module InfluxDB
  class PingError < StandardError
    attr_reader :cause
    def initialize(cause=nil)
      @cause = cause
    end
  end

  class ResultError < StandardError
    attr_reader :cause
    def initialize(cause=nil)
      @cause = cause
    end
  end

  class NoFieldsError < StandardError
  end

  class InvalidFieldType < StandardError
    def initialize(value)
      super("invalid field type: #{value.class}")
    end
  end
end
