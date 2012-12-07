require 'sinatra'
require 'moneta/memory'

class Application < Sinatra::Base
  register Sinatra::Partial

  set :global_cache, Hash.new{|h,k| h[k] = Moneta::Memory.new }

  before do
    session[:cache_key] ||= SecureRandom.uuid
    @cache = settings.global_cache[session[:cache_key]]
  end

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
    haml :index
  end

  # AUTH
  get '/login' do
    redirect github.authorize_url :redirect_uri => url('auth/callback'), :scope => 'repo'
  end

  get '/logout' do
    session.clear
    redirect to('/')
  end

  get '/auth/callback' do
    authorization_code = params[:code]
    token = github.get_token authorization_code
    session[:access_token] = token.token
    redirect to('/')
  end
  # /AUTH

  get '/organizations/:org_name/teams/:id' do
    @team         = team(params[:id])
    @organization = organization(params[:org_name])
    haml :team
  end

  get '/repos/:user/:repo' do
    @organization = organization(params[:user])
    @repo = repo(params[:user], params[:repo])
    haml :repos
  end

  helpers do
    def cache(key, options = {}, &block)
      options = {expires_in: 60}.merge(options)
      @cache.fetch(key) do
        @cache.store(key, block.call, options)
      end
    end

    def authenticated?
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

    def organizations
      cache('organizations') do
        github.orgs.list
      end
    end

    def organization_repos(organization)
      cache("organizations:#{organization.login}:repos", expires_in: 3600) do
        github.repos.list :org => organization.login
      end
    end

    def teams(organization)
      cache("organizations:#{organization.login}:teams", expires_in: 3600) do
        github.organizations.teams.list(organization.login)
      end
    end

    def team(id)
      cache("teams:#{id}", expires_in: 3600) do
        github.orgs.teams.get id
      end
    end

    def organization(org_name)
      cache("organizations:#{org_name}", expires_in: 3600) do
        github.orgs.get org_name
      end
    end

    def pull_requests(repo)
      login = repo.owner.login
      github.pull_requests.list login, repo.name
    end

    def repo(user, repo_name)
      cache("organizations:#{user}:repos:#{repo_name}", expires_in: 3600) do
        github.repos.get user, repo_name
      end
    end
  end
end
