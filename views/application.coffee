window.App = Ember.Application.create
  # ApplicationView: Ember.View.extend
  # ApplicationController: Ember.Controller.extend()

  # store: DS.Store.create
  #   revision: 8
  #   adapter: DS.RESTAdapter.create()

  # Router: Ember.Router.extend
  #   root:  Ember.Route.extend
  #     index: Ember.Route.extend
  #       root: '/'

  ready: ->
    console.log 'Ember application loaded'
    App.helloWorldView.append()
    App.UserView.create().append()

# App.Organization = Ember.Object.extend
#   login: ''

# App.organizationsController = Ember.ArrayController.create
#   content: []
#   init: ->
#     @pushObject(
#       App.Organization.create
#         login: 'henk'
#     )
#     @pushObject(
#       App.Organization.create
#         login: 'piet'
#     )
#     @pushObject(
#       App.Organization.create
#         login: 'klass'
#     )
#     @pushObject(
#       App.Organization.create
#         login: 'jan'
#     )
#     @pushObject(
#       App.Organization.create
#         login: 'sjaak'
#     )

# App.OrganizationView = Ember.View.extend()
# App.orgView = Ember.View.create().append()

App.helloWorldView = Ember.View.create
  templateName: 'hello-world'
  name: "Bob"
  special: 'henk'
  edit: ->
    console.log 'henk henk'

App.userController = Ember.Object.create
  content: Ember.Object.create
    firstName: "Albert"
    lastName: "Hofmann"
    posts: 25
    hobbies: "Riding bicycles"
    awesome: false

App.UserView = Ember.View.extend
  templateName: 'user'
  firstNameBinding: 'App.userController.content.firstName'
  lastNameBinding: 'App.userController.content.lastName'

App.InfoView = Ember.View.extend
  special: 'btn'
