require "excon"
require "stringio"

module Excon
  class SocketResponse
    def initialize(socket)
      @socket = socket
      @buffer = nil
      @bytes_left = 0
      @eof = false
      @eoferror = false
    end

    def eof?
      @eof
    end

    def read(length=nil, outbuf=nil)
      raise(EOFError) if @eoferror
      if eof?
        @eoferror = true
        return nil
      end

      buffer = StringIO.new
      buffer.binmode
      if length
        while length > 0
          if @bytes_left == 0
            @bytes_left = @socket.readline.chomp!.to_i(16)
            if @bytes_left == 0
              @eof = true
              if buffer.size == 0
                @eoferror = true
                return nil
              else
                return buffer.string
              end
            end
          end

          chunk = @socket.read([length, @bytes_left].min)
          @bytes_left -= chunk.bytesize
          length -= chunk.bytesize
          buffer.write(chunk)
          @socket.read(2)
        end

        if outbuf
          outbuf.tap { outbuf << buffer.string }
        else
          buffer.string.empty? ? nil : buffer.string
        end
      else
        if @buffer
          buffer.write(@buffer)
          @buffer = nil
        end

        while (chunk_size = @socket.readline.chomp!.to_i(16)) > 0 do
          buffer.write(@socket.read(chunk_size))
          @socket.read(2)
        end
        @eof = true
      end
      buffer.string
    end

    def close
      @socket.close
    end

    def self.parse(socket, datum)
      begin
        line = socket.readline
      end until status = line[9, 3].to_i

      reason_phrase = line[13..-3]

      datum[:response] = {
        :body => nil,
        :cookies => [],
        :host => datum[:host],
        :headers => Excon::Headers.new,
        :path => datum[:path],
        :port => datum[:port],
        :status => status,
        :status_line => line,
        :reason_phrase => reason_phrase
      }
      Excon::Response.parse_headers(socket, datum)

      transfer_encoding_chunked = false
      if key = datum[:response][:headers].keys.detect {|k| k.casecmp("Transfer-Encoding") == 0}
        encodings = Excon::Utils.split_header_value(datum[:response][:headers][key])
        if (encoding = encodings.last) && encoding.casecmp("chunked") == 0
          transfer_encoding_chunked = true
        end
      end

      if transfer_encoding_chunked
        socket = SocketResponse.new(socket)
      end
      datum[:response][:body] = socket

      datum
    end

    class Middleware < Excon::Middleware::Base
      def response_call(datum)
        unless datum.has_key?(:response)
          conn = datum[:connection]
          socket = conn.send(:socket)
          datum = SocketResponse.parse(socket, datum)

          # Remove the socket from the connection sockets so it doesn't get closed
          # or reused. We now take ownership of the socket.
          if socket_key = conn.instance_variable_get("@socket_key")
            conn.send(:sockets).delete(socket_key)
          end
        end
        super
      end
    end
  end
end
