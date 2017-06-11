require "excon/socket_response"

module InfluxDB
  class Querier
    def initialize(client, opts={})
      @client = client
      @opts = opts
    end

    def execute(q, opts={})
      select(q) do |result|
        result.discard
      end
    end

    def select(q, opts={}, &block)
      resp = raw(q, opts.merge!(format: :msgpack))
      cur = Cursor.new(resp.body)
      return cur unless block_given?

      begin
        cur.each(&block)
      ensure
        cur.close
      end
    end

    def raw(q, opts={})
      opts = @opts.merge(opts)
      values = {}
      values["db"] = opts[:db] if opts.has_key?(:db)
      if opts[:chunked]
        values["chunked"] = "true"
        values["chunk_size"] = opts[:chunk_size] if opts.has_key?(:chunk_size)
      end
      values["pretty"] = "true" if opts[:pretty]
      values["async"] = "true" if opts[:async]
      values["q"] = q

      headers = {}
      headers["Accept"] = case (opts[:format] || :json)
      when :csv
        "text/csv"
      when :msgpack
        "application/x-msgpack"
      when :json
        "application/json"
      else
        opts[:format]
      end

      @client.connection.post(
        path: "/query",
        headers: headers,
        query: values,
        middlewares: [Excon::SocketResponse::Middleware]
      )
    end
  end
end
