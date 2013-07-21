
class Idea extends Backbone.Model
  idAttribute: "_id"
  validate: (attrs, options) ->
    if (attrs.title.length < 3)
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
    #Optimize:
    @$el.find(".title").html _.template("<input class=\"editBox\" type=\"text\" value=\"<%= title %>\">", @model.attributes)
    @$el.find("input").focus()
  updateIdea: (e) ->
    # if e.keyCode is 13
    #   if (@$el.find("input").val().length < 50) and (@$el.find("input").val().length > 2)
    #     @model.set "title", $(".editBox").val()
    #     @model.save()
    #     return
    #   alert "Ideas must be between 3 and 49 characters in length. Try again."
    #DRY this up. You use it in both SAVE and UPDATE views
    if e.keyCode is 13
      @model.save {title: $(".editBox").val()},
        success: (model, response) =>
          $(".inputBox").val ""
          @collection.fetch()
        error: (model, response)   =>
          #TODO: Real errors.
          alert 'Whoops!'
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
      #Put this into a validation. Use the error callback.
      # if ($(".inputBox").val().length < 50) and ($(".inputBox").val().length > 2)
      #   newIdea = new Idea()
      #   newIdea.set "title", $(".inputBox").val()
      #   newIdea.save()
      #   $(".inputBox").val ""
      #   @collection.fetch()
      # #wtf. Why won't it automatically repopulate?
      # else
      #   alert "Ideas must be between 3 and 49 characters in length. Try again."


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
