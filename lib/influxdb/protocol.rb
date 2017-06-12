module InfluxDB
  module Protocol
    class V1
      def encode(w, pt)
        if pt.fields.nil? || pt.fields.empty?
          raise NoFieldsError.new
        end

        buffer = StringIO.new
        buffer.write(pt.name)
        unless pt.tags.nil? || pt.tags.empty?
          pt.tags.each do |k, v|
            buffer.write(",")
            buffer.write(k)
            buffer.write("=")
            buffer.write(v)
          end
        end
        buffer.write(" ")

        first = true
        pt.fields.each do |k, v|
          buffer.write(",") unless first
          first = false
          buffer.write(k)
          buffer.write("=")
          case v
          when Float
            buffer.write(v.to_s)
          when Integer
            buffer.write(v.to_s + "i")
          when String, Symbol
            buffer.write('"' + v + '"')
          when TrueClass
            buffer.write("t")
          when FalseClass
            buffer.write("f")
          else
            raise InvalidFieldType.new(v)
          end
        end
        buffer.write("\n")

        # Write out the buffer to the writer.
        w.write(buffer.string)
      end

      def content_type
        "application/x-influxdb-line-protocol-v1"
      end
    end
  end

  DefaultWriteProtocol = Protocol::V1.new
end
