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
end
