module InfluxDB
  class Client
    attr_reader :connection

    def initialize(url = nil, opts = {})
      url, opts = nil, url if url.is_a?(Hash)
      url = "http://127.0.0.1:8086" if url.nil?
      opts[:persistent] = true unless opts.has_key?(:persistent)
      @connection = Excon.new(url, opts)
    end

    def ping
      resp = connection.get(path: "/ping")
      if resp.status/100 != 2
        raise PingError.new("incorrect status code")
      end
      return {version: resp.headers["X-Influxdb-Version"]}
    rescue Excon::Error::Socket => ex
      raise PingError.new(ex)
    end

    def execute(q, opts={})
      querier(opts).execute(q)
    end

    def select(q, opts={})
      querier(opts).select(q)
    end

    def raw(q, opts={})
      querier(opts).raw(q)
    end

    def querier(opts={})
      Querier.new(self, opts)
    end

    def writer(opts={})
      Querier.new(self, opts)
    end
  end
end
