$(document).ready ($) ->
  console.log "App loading..."
  Idea = Backbone.Model.extend(
    defaults: ->
      title: "none set"
      url: ->
        "/ideas"

    initialize: ->
      @set title: @defaults().title  unless @get("title")
      @set url: @defaults().url
  )
  IdeaView = Backbone.View.extend(
    tagName: "li"
    initialize: ->
      
      #Javascript is dumb...
      _.bindAll this, "render"
      
      # implemented so that it will refresh when the model changes...
      @model.bind "change", @render
      @template = _.template($("#idea-template").html())

    render: ->
      renderedContent = @template(@model.toJSON())
      $(@el).html renderedContent
      
      #Return 'this' so that method chaining is possible
      this
  )
  Ideas = Backbone.Collection.extend(
    model: Idea
    url: "/ideas"
  )
  IdeasView = Backbone.View.extend(
    initialize: ->
      _.bindAll this, "render"
      @template = _.template($("#ideas-template").html())
      @collection.bind "reset", @render

    render: ->
      console.log this
      $ideas = undefined
      collection = undefined
      $(@el).html @template
      
      #using this.$() scopes it to the particular DOM element
      $ideas = @$(".ideas")
      @collection.each (idea) ->
        ideaItem = new IdeaView(
          model: idea
          collection: collection
        )
        $ideas.append ideaItem.render().el

      this
  )
  UnpopularIdeas = Backbone.Router.extend(
    routes:
      "": "home"

    initialize: ->
      ideas = new Ideas
      ideas.fetch()
      @stream = new IdeasView(collection: ideas)

    home: ->
      $("#container").append @stream.render().el
  )
  window.App = new UnpopularIdeas
  Backbone.history.start()