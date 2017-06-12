module InfluxDB
  class HTTPWriter
    attr_accessor :db

    attr_accessor :rp

    attr_accessor :consistency

    attr_reader :protocol

    alias_method :database, :db

    alias_method :retention_policy, :rp

    def initialize(client, opts={})
      @client = client
      @db = opts[:db] || opts[:database]
      @rp = opts[:rp] || opts[:retention_policy]
      @consistency = opts[:consistency]
      @protocol = opts[:protocol] || DefaultWriteProtocol
    end

    def write(data)
      return 0 if data.empty?
      values = {}
      values["db"] = @db if @db
      values["rp"] = @rp if @rp

      headers = {"Content-Type" => protocol.content_type}
      resp = @client.connection.post(
        path: "/write",
        query: values,
        body: data,
      )

      case resp.status / 100
      when 2
        return data.size
      when 4
        # This is a client error. Read the error message to learn what type of
        # error this is.
        raise
      else
      end
    end
  end
end
