window.App = Ember.Application.create
  ready: ->
    console.log 'Ember application loaded'
    App.OrganizationListView.create().appendTo('aside')

App.Organization = Ember.Object.extend()

App.organizationsController = Ember.ArrayController.create
  content: []
  init: ->
    @pushObject(
      App.Organization.create
        login: 'henk'
        teams: [
          { name: 'team1' }, { name: 'team2' }, { name: 'team3'}
        ]
    )
    @pushObject(
      App.Organization.create
        login: 'piet'
        teams: [
          { name: 'team1' }, { name: 'team2' }, { name: 'team3'}
        ]
    )

App.OrganizationListView = Ember.View.extend
  templateName: 'organization_list'
  tagName: 'ul'
  classNames: ['nav', 'nav-list']
  organizationsBinding: 'App.organizationsController.content'