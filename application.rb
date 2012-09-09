require 'sinatra'

class Application < Sinatra::Base
  configure do
    enable :sessions
    set :session_secret, "Awesomeness_ensured"
    set :public_folder, File.dirname(__FILE__) + '/public'
    set :views, File.dirname(__FILE__) + '/views'
  end

  configure :development do
    set :github, {
      client_id: '1d902f655692eff5aaed',
      client_secret: 'e7e55f9b39f3123341b1bd759f1087edc351bb5b'
    }
  end

  get '/' do
    p session[:access_token]
    @test = session[:access_token]
    @github = github
    haml :index
  end

  get '/login' do
    redirect github.authorize_url :redirect_uri => 'http://localhost:9393/auth/callback', :scope => 'repo'
  end

  get '/auth/callback' do
    authorization_code = params[:code]
    token = github.get_token authorization_code
    session[:access_token] = token.token
    redirect to('/')
  end

  helpers do
    def github
      if session[:access_token]
        Github.configure do |config|
          config.oauth_token = session[:access_token]
          config.adapter     = :net_http
        end
        ENV['debug'] = 'true'
      end
      p "session[:access_token]"
      p session[:access_token]
      Github.new settings.github
    end
  end
end