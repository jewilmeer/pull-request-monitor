App = new Backbone.Marionette.Application(
  root: '/'
)

App.addRegions
  sidebar: 'aside'

App.Models = {}
App.Collections = {}
App.Views = {}
App.instance_vars = {}

# ----- MODELS
class App.Models.Organization extends Backbone.Model
  initialize: (options) ->
    {@name} = options
    @repositories = new App.Collections.Repositories( organization: @)
class App.Models.PullRequest extends Backbone.Model
class App.Models.Repository extends Backbone.Model
  defaults:
    name: null
    user: null
    description: null
    open_issues_count: null
    links: null
  initialize: (options) ->
    if options.user && options.name
      @pull_requests = new App.Collections.PullRequests(user: options.user, repo: options.name)
      @pull_requests.fetch()

# ----- COLLECTIONS
class App.Collections.Repositories extends Backbone.Collection
  model: App.Models.Repository
  url: ->
    "/organizations/#{@organization.organization}/repos.json"

class App.Collections.PullRequests extends Backbone.Collection
  model: App.Models.PullRequest
  url: ->
    "/pull_requests/#{@user}/#{@repo}.json"

  initialize: (options) ->
    {@user, @repo} = options

# ----- VIEWS
class App.Views.EmptyRepoItem extends Backbone.Marionette.ItemView
  template: '#tmp-emtpy-repo-item'
class App.Views.RepoItem extends Backbone.Marionette.ItemView
  tagName: 'li'
  template: '#tpl-repo-item'
  templateHelpers: () ->
    nr_of_pull_requests: () ->
      "1234"
    nr_of_issues: () ->
      "4567"

class App.Views.RepoListView extends Backbone.Marionette.CollectionView
  itemView: App.Views.RepoItem
  emptyView: App.Views.EmptyRepoItem
  tagName: 'ul'
  className: 'nav nav-list well'

App.addInitializer ->
  @instance_vars.organization = new App.Models.Organization( name: 'InspireNL' )
  @instance_vars.repositories = new App.Collections.Repositories()
  @instance_vars.repositories.organization= organization: @instance_vars.organization.name

  # @instance_vars.repositories = new App.Collections.Repositories( organization: @instance_vars.organization )
  console.log 'repositories', @instance_vars.repositories.length
  # @sidebar.show(collection: @instance_vars.repositories)
  @sidebar.show( new App.Views.RepoListView( collection: @instance_vars.repositories) )

  @instance_vars.repositories.fetch( )

App.addInitializer ->
  console.log 'app starting'

$ ->
  # make app global
  window.App = App
  App.start()
