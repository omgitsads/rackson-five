module Rack
  class RacksonFive < Struct.new :app, :options
    def call(env)
      request = Rack::Request.new(env)
      if request.path_info =~ /^\/rackson-five\/(.+)$/
        rackson_five_request($1)
      else
        jacksonify(env)
      end
    end
    
    private
      def rackson_five_request(path)
        if path == "rackson-five.png"
          [200, {"Content-Type" => "image/png"}, read_file("images", "group.png")]
        elsif path == "tile.png"
          [200, {"Content-Type" => "image/png"}, read_file("images","tile.png")]
        elsif path == "rackson-five.mid"
          [200, {"Content-Type" => "audio/midi"}, read_file("midi","want_you_back.mid")]
        end
      end
    
      def jacksonify(env)
        status, headers, response = app.call(env)
        if headers["Content-Type"] =~ /text\/html|application\/xhtml\+xml/
          body = ""
          response.each { |part| body << part }
          index = body.rindex("</body>")
          if index
              body.insert(index, read_file("html", "rackson-five.html"))
            headers["Content-Length"] = body.length.to_s
            response = [body]
          end
        end
        [status, headers, response]
      end
      
      def read_file(type, filename)
        ::File.open(::File.join(::File.dirname(__FILE__),type.to_s,filename),"r").read
      end
  end
end