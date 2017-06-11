module InfluxDB
  class Point
    attr_accessor :name, :tags, :fields, :time

    def initialize(name:, tags: nil, fields: nil, time: nil)
      @name = name
      @tags = tags.nil? ? {} : tags
      @fields = fields
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
    end
  end
end
