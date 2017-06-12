module InfluxDB
  class Point
    attr_accessor :name, :tags, :fields, :time

    def initialize(name:, tags: nil, fields: nil, time: nil)
      @name = name
      @tags = tags.nil? ? {} : tags
      @fields = fields.nil? ? {} : fields
      @time = time
    end

    def with_fields(fields)
      @fields = fields
      self
    end

    def with_tags(tags)
      @tags = tags
      self
    end

    def write_to(w)
      protocol = DefaultWriteProtocol
      if w.respond_to?(:protocol)
        protocol = w.protocol
      end
      protocol.encode(w, self)
    end
  end
end
