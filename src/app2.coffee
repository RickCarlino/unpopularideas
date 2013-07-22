
class Idea extends Backbone.Model
  idAttribute: "_id"
  validate: (attrs, options) ->
    if (attrs.title.length < 4)
      return "Title is too short"
    if (attrs.title.length > 50)
      return "Title is too long"
  urlRoot: "/ideas"

class IdeaView extends Backbone.View
  tagtitle: "li"
  initialize: ->
    _.bindAll this, "render", "remove"
    @model.bind "change", @render
    @model.bind "destroy", @remove
    @template = _.template($("#idea-template").html())
  events:
    "click .destroy": "clear"
    "dblclick .title": "edit"
    "keypress .editBox": "updateIdea"
  clear: ->
    @model.destroy()
  edit: ->
    @$el.find(".title").html _.template("<input class=\"editBox\" type=\"text\" value=\"<%= title %>\">", @model.attributes)
    @$el.find("input").focus()
  updateIdea: (e) =>
    if e.keyCode is 13
      @model.set 'title', $(".editBox").val()
      @model.save null,
        success: (model, response) =>
          $(".inputBox").val ""
        error: (model, response)   =>
          console.error 'Unable to save your idea. Try again or check your internet connection.'
      alert @model.validationError unless @model.isValid()
  render: ->
    renderedContent = @template(@model.toJSON())
    $(@el).html renderedContent
    #Return 'this' so that method chaining is possible
    this


class Ideas extends Backbone.Collection
  model: Idea
  url: "/ideas"


class IdeasView extends Backbone.View
  initialize: ->
    _.bindAll this, "render"
    @template = _.template($("#ideas-template").html())
    @collection.bind "reset", @render
    @collection.bind "change", @render
  render: ->
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
  events:
    "keypress .inputBox": "newIdea"
  newIdea: (e) =>
    if e.keyCode is 13
      newIdea = new Idea()
      newIdea.save {title: $(".inputBox").val()},
        success: (model, response) =>
          
          $(".inputBox").val ""
          @collection.fetch()
        error: (model, response)   =>
          
          #TODO: Real errors.
          alert 'Whoops!'
        

class UnpopularIdeas extends Backbone.Router
  routes:
    "": "home"
  initialize: ->
    ideas = new Ideas()
    ideas.fetch()
    @stream = new IdeasView(collection: ideas)
  home: ->
    $("#container").append @stream.render().el

$ ->
  window.App = new UnpopularIdeas()
  Backbone.history.start()
