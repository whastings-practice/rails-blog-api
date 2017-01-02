require "rack-proxy"

class AssetProxy < Rack::Proxy
  def perform_request(env)
    request = Rack::Request.new(env)
    if request.path =~ /\.(js|css)$/
      # proxy...
      env["HTTP_HOST"] = "localhost:8000"
      env["REQUEST_PATH"] = "/#{request.fullpath}"
      super(env)
    else
      @app.call(env)
    end
  end
end
