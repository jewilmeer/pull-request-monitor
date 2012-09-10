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
  configure :production do
    set :github, {
      client_id: '8e0a05cdfb50558d4ddb',
      client_secret: '60c07b51bcd14955dc7b923b7f266bde5bec1dc5'
    }
  end

  get '/' do
    @test = session[:access_token]
    @github = github
    haml :index
  end

  # AUTH
  get '/login' do
    redirect github.authorize_url :redirect_uri => url('auth/callback'), :scope => 'repo'
  end

  get '/auth/callback' do
    authorization_code = params[:code]
    token = github.get_token authorization_code
    session[:access_token] = token.token
    redirect to('/')
  end
  # /AUTH

  get '/teams/:id' do
    @github = github
    @team   = github.orgs.teams.get params[:id]
    @repos  = github.orgs.teams.list_repos params[:id]
    haml :team
  end

  get '/repos/:id' do
    haml :repos
  end

  helpers do
    def authorized?
      !!session[:access_token]
    end

    def github
      if session[:access_token]
        Github.configure do |config|
          config.oauth_token = session[:access_token]
          config.adapter     = :net_http
        end
        ENV['debug'] = 'true'
      end
      Github.new settings.github
    end
  end
end