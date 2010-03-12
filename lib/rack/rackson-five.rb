module Rack
  class RacksonFive < Struct.new :options
    def initialize(app)
      @app = app
    end
    
    def call(env)
      request = Rack::Request.new(env)
      if request.path_info =~ /^\/rackson-five\/(.+)$/
        rackson_five_request($1)
      else
        jacksonify(env)
      end
    end
    
    def rackson_five_request(path)
      if path == "rackson-five.png"
        data = ::File.open(::File.join(::File.dirname(__FILE__),"images","group.png"),"r").read
        [200, {"Content-Type" => "image/png"},data]
      elsif path == "rackson-five.mid"
        data = ::File.open(::File.join(::File.dirname(__FILE__),"midi","want_you_back.mid"),"r").read
        [200, {"Content-Type" => "audio/midi"},data]
      end
    end
    
    def jacksonify(env)
      status, headers, response = @app.call(env)
      if headers["Content-Type"] =~ /text\/html|application\/xhtml\+xml/
        body = ""
        response.each { |part| body << part }
        index = body.rindex("</body>")
        if index
            body.insert(index, '<img src="/rackson-five/rackson-five.png" style="position:absolute; bottom:0; right:0;" /><embed src="/rackson-five/rackson-five.mid" autostart="true" loop="1" hidden="true" />')
          headers["Content-Length"] = body.length.to_s
          response = [body]
        end
      end
      [status, headers, response]
    end
    
    def member
      all_members = [:group, :micheal, :tito, :jermaine, :randy, :marlon, :jackie]
      available_members = all_members - (all_members - options[:members])
    end
  end
end